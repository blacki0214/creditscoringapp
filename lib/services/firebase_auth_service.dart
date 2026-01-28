import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';

class FirebaseAuthService {
  final FirebaseService _firebase = FirebaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      // Create user account
      final credential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final userData = {
        'uid': credential.user!.uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'authMethod': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
      };

      // Add avatarUrl if provided
      if (avatarUrl != null) {
        userData['avatarUrl'] = avatarUrl;
      }

      await _firebase.usersCollection.doc(credential.user!.uid).set(userData);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebase.auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebase.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _firebase.auth.currentUser?.reload();
    return _firebase.auth.currentUser?.emailVerified ?? false;
  }

  // Sign in with phone number (OTP)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(PhoneAuthCredential) verificationCompleted,
  }) async {
    await _firebase.auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP code
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _firebase.auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebase.auth.signOut();
  }


  // Get current user stream
  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();

  // Get current user
  User? get currentUser => _firebase.auth.currentUser;

  // === PHONE AUTHENTICATION ===
  
  // Send OTP to phone number
  Future<String> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      String verificationIdResult = '';
      
      await _firebase.auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _firebase.auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationIdResult = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationIdResult = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      
      return verificationIdResult;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Verify OTP and sign in
  Future<UserCredential> verifyPhoneOTP({
    required String verificationId,
    required String smsCode,
    String? fullName,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebase.auth.signInWithCredential(credential);
      
      // Create/update user document if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final userData = {
          'uid': userCredential.user!.uid,
          'phoneNumber': userCredential.user!.phoneNumber,
          'authMethod': 'phone',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'profileComplete': false,
        };
        
        if (fullName != null) {
          userData['fullName'] = fullName;
        }
        
        await _firebase.usersCollection
            .doc(userCredential.user!.uid)
            .set(userData);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // === GOOGLE SIGN-IN ===
  
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebase.auth.signInWithCredential(credential);
      
      // Create/update user document if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final userData = {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'fullName': userCredential.user!.displayName ?? 'User',
          'phoneNumber': userCredential.user!.phoneNumber ?? '',
          'avatarUrl': userCredential.user!.photoURL,
          'authMethod': 'google',
          'googleId': googleUser.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'profileComplete': true, // Google users have complete profile
        };
        
        await _firebase.usersCollection
            .doc(userCredential.user!.uid)
            .set(userData);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'Email is already in use. Please login or use a different email.';
      case 'user-not-found':
        return 'Account not found. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'Account has been disabled.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification session. Please request a new code.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
