import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';

class FirebaseEkycService {
  final FirebaseService _firebase = FirebaseService();

  // Start EKYC session
  Future<String> startEkycSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      final docRef = await _firebase.ekycLogsCollection.add({
        'userId': userId,
        'sessionId': sessionId,
        'status': 'pending',
        'verificationType': 'id_card',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start EKYC session: $e');
    }
  }

  // Update EKYC session status
  Future<void> updateEkycStatus({
    required String logId,
    required String status,
    double? confidence,
    String? errorMessage,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'verified') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      if (confidence != null) {
        updateData['confidence'] = confidence;
      }

      if (errorMessage != null) {
        updateData['errorMessage'] = errorMessage;
      }

      await _firebase.ekycLogsCollection.doc(logId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update EKYC status: $e');
    }
  }

  // Upload EKYC image to Firebase Storage
  Future<String> uploadEkycImage({
    required String userId,
    required String sessionId,
    required File imageFile,
    required String imageType, // front_id, back_id, face, signature
  }) async {
    try {
      // Create storage path
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageType.jpg';
      final storageRef = _firebase.storage
          .ref()
          .child('ekyc_images')
          .child(userId)
          .child(sessionId)
          .child(fileName);

      // Upload file
      final uploadTask = await storageRef.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save image metadata to Firestore
      await _firebase.ekycImagesCollection.add({
        'userId': userId,
        'sessionId': sessionId,
        'imageType': imageType,
        'storageUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileSize': await imageFile.length(),
        'mimeType': 'image/jpeg',
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload EKYC image: $e');
    }
  }

  // Get EKYC logs for user
  Future<List<Map<String, dynamic>>> getUserEkycLogs(String userId) async {
    try {
      final querySnapshot = await _firebase.ekycLogsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get EKYC logs: $e');
    }
  }

  // Get EKYC images for session
  Future<List<Map<String, dynamic>>> getSessionImages(String sessionId) async {
    try {
      final querySnapshot = await _firebase.ekycImagesCollection
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('uploadedAt')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get session images: $e');
    }
  }

  // Delete EKYC image from storage
  Future<void> deleteEkycImage(String imageUrl) async {
    try {
      final ref = _firebase.storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete EKYC image: $e');
    }
  }
}
