import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirebaseUserService {
  final FirebaseService _firebase = FirebaseService();

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firebase.usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user profile stream
  Stream<DocumentSnapshot> getUserProfileStream(String userId) {
    return _firebase.usersCollection.doc(userId).snapshots();
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firebase.usersCollection.doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Complete user profile (onboarding)
  Future<void> completeUserProfile({
    required String userId,
    required String fullName,
    required DateTime dateOfBirth,
    required String nationalId,
    required String address,
    required String city,
    required double monthlyIncome,
    required String employmentStatus,
    required double yearsEmployed,
    required String homeOwnership,
  }) async {
    try {
      await _firebase.usersCollection.doc(userId).update({
        'fullName': fullName,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'nationalId': nationalId,
        'address': address,
        'city': city,
        'monthlyIncome': monthlyIncome,
        'employmentStatus': employmentStatus,
        'yearsEmployed': yearsEmployed,
        'homeOwnership': homeOwnership,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to complete user profile: $e');
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final doc = await _firebase.usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['profileComplete'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user document and related data
      final batch = _firebase.firestore.batch();
      
      // Delete user document
      batch.delete(_firebase.usersCollection.doc(userId));
      
      // Delete related EKYC logs
      final ekycLogs = await _firebase.ekycLogsCollection
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in ekycLogs.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete related applications
      final applications = await _firebase.creditApplicationsCollection
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in applications.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }
}
