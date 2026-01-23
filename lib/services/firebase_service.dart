import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get ekycLogsCollection => _firestore.collection('ekyc_logs');
  CollectionReference get ekycImagesCollection => _firestore.collection('ekyc_images');
  CollectionReference get creditApplicationsCollection => _firestore.collection('credit_applications');
  CollectionReference get loanOffersCollection => _firestore.collection('loan_offers');
  CollectionReference get applicationHistoryCollection => _firestore.collection('application_history');

  // Current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;
}
