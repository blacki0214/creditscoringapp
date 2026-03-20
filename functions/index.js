const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

function normalizeData(input) {
  if (!input || typeof input !== "object") {
    return {};
  }

  const out = {};
  for (const [key, value] of Object.entries(input)) {
    if (value === null || value === undefined) {
      continue;
    }

    if (typeof value === "object") {
      out[key] = JSON.stringify(value);
      continue;
    }

    out[key] = String(value);
  }

  return out;
}

exports.dispatchNotificationPush = onDocumentCreated(
  {
    document: "notifications/{notificationId}",
    region: "asia-southeast1",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const notificationId = event.params.notificationId;
    const ref = snapshot.ref;
    const data = snapshot.data() || {};

    // Only dispatch pushes that are explicitly requested and still pending.
    if (data.shouldSendPush !== true || data.pushStatus !== "pending") {
      logger.debug("Skip push dispatch", { notificationId });
      return;
    }

    const userId = data.userId;
    if (!userId) {
      await ref.set(
        {
          pushStatus: "failed",
          pushError: "missing_user_id",
          pushFailedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return;
    }

    try {
      // Claim this job so duplicate invocations cannot send twice.
      await admin.firestore().runTransaction(async (tx) => {
        const fresh = await tx.get(ref);
        const freshData = fresh.data() || {};
        if (freshData.pushStatus !== "pending") {
          throw new Error("push_not_pending");
        }
        tx.update(ref, {
          pushStatus: "processing",
          pushProcessingAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
    } catch (err) {
      if (err.message === "push_not_pending") {
        logger.debug("Notification already processed", { notificationId });
        return;
      }
      throw err;
    }

    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    const userData = userDoc.data() || {};
    const token = userData.fcmToken;

    if (!token) {
      await ref.set(
        {
          pushStatus: "failed",
          pushError: "missing_fcm_token",
          pushFailedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      logger.warn("Missing FCM token", { notificationId, userId });
      return;
    }

    const payload = {
      token,
      notification: {
        title: data.title || "Notification",
        body: data.body || "You have a new update",
      },
      data: {
        notificationId: String(notificationId),
        userId: String(userId),
        type: data.type ? String(data.type) : "general",
        ...normalizeData(data.data),
      },
      android: {
        priority: "high",
        notification: {
          channelId: "credit_scoring_updates",
          sound: "default",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    try {
      const messageId = await admin.messaging().send(payload);
      await ref.set(
        {
          pushStatus: "sent",
          pushMessageId: messageId,
          pushSentAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      logger.info("Push sent", { notificationId, userId, messageId });
    } catch (err) {
      const errorCode = err && err.code ? String(err.code) : "unknown_error";
      const errorMessage = err && err.message ? String(err.message) : "unknown";
      await ref.set(
        {
          pushStatus: "failed",
          pushError: `${errorCode}:${errorMessage}`,
          pushFailedAt: admin.firestore.FieldValue.serverTimestamp(),
          pushRetryCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      // If the token is invalid, clear it to avoid repeated failures.
      if (errorCode.includes("registration-token") || errorCode.includes("invalid-argument")) {
        await admin.firestore().collection("users").doc(userId).set(
          {
            fcmToken: admin.firestore.FieldValue.delete(),
            fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }

      logger.error("Push send failed", { notificationId, userId, errorCode, errorMessage });
    }
  },
);
