const crypto = require("node:crypto");
const nodemailer = require("nodemailer");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const VERIFICATION_TOKEN_TTL_MINUTES = 30;
const RESEND_COOLDOWN_SECONDS = 60;
const ALLOWED_STUDENT_DOMAIN_SUFFIXES = ["edu.vn", "student.swin.edu.au"];
const SMTP_USER = defineSecret("SMTP_USER");
const SMTP_APP_PASSWORD = defineSecret("SMTP_APP_PASSWORD");
const SMTP_FROM = defineSecret("SMTP_FROM");

function jsonResponse(res, status, body) {
  res.status(status).json(body);
}

function htmlResponse(res, status, title, message, color) {
  res.status(status).send(`<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${title}</title>
    <style>
      body { font-family: Arial, sans-serif; background: #f7f8fc; margin: 0; padding: 24px; }
      .card { max-width: 560px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 24px; border: 1px solid #e6ebff; }
      h1 { margin: 0 0 10px; color: #1a1f3f; font-size: 22px; }
      p { margin: 0; color: #2f365f; line-height: 1.5; }
      .badge { display: inline-block; margin-bottom: 12px; padding: 6px 10px; border-radius: 999px; color: #fff; background: ${color}; font-size: 12px; }
    </style>
  </head>
  <body>
    <div class="card">
      <span class="badge">Student Email Verification</span>
      <h1>${title}</h1>
      <p>${message}</p>
    </div>
  </body>
</html>`);
}

function extractBearerToken(req) {
  const authHeader = req.headers.authorization || "";
  if (!authHeader.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.substring("Bearer ".length).trim();
}

async function authenticateRequest(req, res) {
  const token = extractBearerToken(req);
  if (!token) {
    jsonResponse(res, 401, { error: "missing_auth_token" });
    return null;
  }

  try {
    return await admin.auth().verifyIdToken(token);
  } catch (err) {
    logger.warn("Invalid auth token", { message: err && err.message ? err.message : "unknown" });
    jsonResponse(res, 401, { error: "invalid_auth_token" });
    return null;
  }
}

function isAllowedStudentDomain(email) {
  const normalized = String(email || "").trim().toLowerCase();
  const atIndex = normalized.lastIndexOf("@");
  if (atIndex < 0 || atIndex === normalized.length - 1) {
    return false;
  }
  const domain = normalized.substring(atIndex + 1);
  return ALLOWED_STUDENT_DOMAIN_SUFFIXES.some((suffix) => domain === suffix || domain.endsWith(`.${suffix}`));
}

function hashToken(rawToken) {
  return crypto.createHash("sha256").update(rawToken).digest("hex");
}

async function sendVerificationEmailViaSmtp({ toEmail, verificationLink }) {
  const smtpUser = SMTP_USER.value();
  const smtpAppPassword = SMTP_APP_PASSWORD.value();
  const fromEmail = SMTP_FROM.value();

  if (!smtpUser || !smtpAppPassword || !fromEmail) {
    throw new Error("missing_smtp_env");
  }

  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
      user: smtpUser,
      pass: smtpAppPassword,
    },
  });

  await transporter.verify();

  const subject = "Verify your student email";
  const html = `
    <div style="font-family:Arial,sans-serif;line-height:1.5;color:#1f2937">
      <h2 style="margin:0 0 12px">Student Email Verification</h2>
      <p>Please verify your student email address by clicking the button below.</p>
      <p>This link expires in ${VERIFICATION_TOKEN_TTL_MINUTES} minutes.</p>
      <p style="margin:20px 0">
        <a href="${verificationLink}" style="background:#4d4af9;color:#ffffff;text-decoration:none;padding:10px 16px;border-radius:8px;display:inline-block">
          Verify Student Email
        </a>
      </p>
      <p>If you did not request this, you can safely ignore this email.</p>
    </div>
  `;

  const mailFrom = `"CreditScore Verification" <${smtpUser}>`;
  const mailOptions = {
    from: mailFrom,
    replyTo: fromEmail && fromEmail !== smtpUser ? fromEmail : undefined,
    to: toEmail,
    subject,
    html,
  };

  const info = await transporter.sendMail(mailOptions);
  logger.info("Verification email send result", {
    messageId: info.messageId,
    response: info.response,
    accepted: info.accepted,
    rejected: info.rejected,
    envelope: info.envelope,
  });
}

exports.sendStudentVerificationEmail = onRequest(
  {
    region: "asia-southeast1",
    cors: true,
    invoker: "public",
    secrets: [SMTP_USER, SMTP_APP_PASSWORD, SMTP_FROM],
  },
  async (req, res) => {
    if (req.method !== "POST") {
      jsonResponse(res, 405, { error: "method_not_allowed" });
      return;
    }

    const decodedToken = await authenticateRequest(req, res);
    if (!decodedToken) {
      return;
    }

    const uid = decodedToken.uid;
    const studentEmail = String(req.body && req.body.studentEmail ? req.body.studentEmail : "").trim().toLowerCase();
    const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

    if (!emailRegex.test(studentEmail)) {
      jsonResponse(res, 400, { error: "invalid_email_format" });
      return;
    }

    if (!isAllowedStudentDomain(studentEmail)) {
      jsonResponse(res, 400, { error: "invalid_student_domain" });
      return;
    }

    const verificationRef = admin.firestore().collection("studentEmailVerification").doc(uid);
    const now = admin.firestore.Timestamp.now();
    const existingSnap = await verificationRef.get();
    const existingData = existingSnap.data() || {};

    if (existingData.resendAvailableAt && typeof existingData.resendAvailableAt.toDate === "function") {
      const resendAvailableAt = existingData.resendAvailableAt.toDate();
      if (resendAvailableAt.getTime() > Date.now()) {
        jsonResponse(res, 429, { error: "resend_cooldown_active" });
        return;
      }
    }

    const rawToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = hashToken(rawToken);
    const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + VERIFICATION_TOKEN_TTL_MINUTES * 60 * 1000);
    const resendAvailableAt = admin.firestore.Timestamp.fromMillis(Date.now() + RESEND_COOLDOWN_SECONDS * 1000);
    const host = req.get("host");
    const verificationLink = `${req.protocol}://${host}/confirmStudentEmail?uid=${encodeURIComponent(uid)}&token=${encodeURIComponent(rawToken)}`;

    await verificationRef.set(
      {
        uid,
        studentEmail,
        tokenHash,
        status: "pending",
        expiresAt,
        resendAvailableAt,
        requestedAt: now,
        updatedAt: now,
      },
      { merge: true },
    );

    try {
      logger.info("Sending verification email", {
        uid,
        studentEmail,
      });

      await sendVerificationEmailViaSmtp({
        toEmail: studentEmail,
        verificationLink,
      });
      jsonResponse(res, 200, {
        ok: true,
        sentTo: studentEmail,
        expiresInMinutes: VERIFICATION_TOKEN_TTL_MINUTES,
      });
    } catch (err) {
      const errorMessage = err && err.message ? err.message : "unknown";
      logger.error("Failed to send student verification email", {
        uid,
        studentEmail,
        error: errorMessage,
      });
      jsonResponse(res, 500, {
        error: "email_delivery_failed",
        detail: errorMessage,
      });
    }
  },
);

exports.confirmStudentEmail = onRequest(
  {
    region: "asia-southeast1",
    cors: true,
    invoker: "public",
  },
  async (req, res) => {
    if (req.method !== "GET") {
      htmlResponse(res, 405, "Invalid Request", "This endpoint only accepts GET requests.", "#d32f2f");
      return;
    }

    const uid = String(req.query.uid || "").trim();
    const token = String(req.query.token || "").trim();

    if (!uid || !token) {
      htmlResponse(res, 400, "Missing Parameters", "The verification link is incomplete. Please request a new email.", "#d32f2f");
      return;
    }

    const verificationRef = admin.firestore().collection("studentEmailVerification").doc(uid);
    const userRef = admin.firestore().collection("users").doc(uid);
    const snap = await verificationRef.get();
    const data = snap.data();

    if (!data) {
      htmlResponse(res, 404, "Verification Not Found", "No pending verification request exists. Please request a new email.", "#d32f2f");
      return;
    }

    if (data.status === "verified") {
      htmlResponse(res, 200, "Already Verified", "This student email was already verified. You can return to the app.", "#2e7d32");
      return;
    }

    const expectedHash = String(data.tokenHash || "");
    const providedHash = hashToken(token);
    if (!expectedHash || expectedHash !== providedHash) {
      htmlResponse(res, 400, "Invalid Link", "The verification link is invalid. Please request a new email.", "#d32f2f");
      return;
    }

    const expiresAt = data.expiresAt && typeof data.expiresAt.toDate === "function"
      ? data.expiresAt.toDate()
      : null;

    if (!expiresAt || expiresAt.getTime() < Date.now()) {
      await verificationRef.set(
        {
          status: "expired",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      htmlResponse(res, 400, "Link Expired", "This verification link has expired. Please request a new email.", "#d32f2f");
      return;
    }

    const studentEmail = String(data.studentEmail || "").trim().toLowerCase();
    const domain = studentEmail.includes("@") ? studentEmail.split("@")[1] : "";

    await admin.firestore().runTransaction(async (tx) => {
      tx.set(
        userRef,
        {
          studentEmail,
          studentEmailDomain: domain,
          studentEmailVerified: true,
          studentEmailVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      tx.set(
        verificationRef,
        {
          status: "verified",
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          tokenHash: admin.firestore.FieldValue.delete(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    });

    htmlResponse(res, 200, "Verification Successful", "Your student email is now verified. Return to the app and tap \"Email Verified\".", "#2e7d32");
  },
);

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
