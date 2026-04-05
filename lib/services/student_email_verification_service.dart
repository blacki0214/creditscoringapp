import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StudentEmailVerificationState {
  const StudentEmailVerificationState({
    required this.isVerified,
    this.studentEmail,
  });

  final bool isVerified;
  final String? studentEmail;
}

class StudentEmailVerificationService {
  static const String _fallbackBaseUrlTemplate =
      'https://asia-southeast1-{projectId}.cloudfunctions.net';

  String _functionsBaseUrlForProject(String projectId) {
    return _fallbackBaseUrlTemplate.replaceFirst('{projectId}', projectId);
  }

  String get _functionsBaseUrl {
    final fromEnv =
        dotenv.env['STUDENT_VERIFY_FUNCTIONS_BASE_URL']?.trim() ?? '';
    final value = fromEnv.isEmpty
        ? _functionsBaseUrlForProject(
            FirebaseAuth.instance.app.options.projectId,
          )
        : fromEnv;
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  List<String> _candidateBaseUrls() {
    final projectId = FirebaseAuth.instance.app.options.projectId;
    final urls = <String>[
      _functionsBaseUrl,
      'https://us-central1-$projectId.cloudfunctions.net',
    ];

    final seen = <String>{};
    return urls.where((url) => seen.add(url)).toList(growable: false);
  }

  Future<void> sendVerificationEmail({required String studentEmail}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final idToken = await user.getIdToken(true);
    final requestBody = jsonEncode({'studentEmail': studentEmail});
    final triedUrls = <String>[];
    String? lastMessage;

    for (final baseUrl in _candidateBaseUrls()) {
      final url = Uri.parse('$baseUrl/sendStudentVerificationEmail');
      triedUrls.add(url.toString());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      if (response.statusCode == 404) {
        lastMessage = 'Verification endpoint not found at $baseUrl.';
        continue;
      }

      String message =
          'Failed to send verification email (HTTP ${response.statusCode}).';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final code = body['error']?.toString();
        final detail = body['detail']?.toString();
        if (code == 'resend_cooldown_active') {
          message = 'Please wait before requesting another email.';
        } else if (code == 'invalid_student_domain') {
          message = 'The email domain is not allowed for student verification.';
        } else if (code == 'missing_auth_token') {
          message = 'Your session is missing. Please sign in again.';
        } else if (code == 'invalid_auth_token') {
          message = 'Your session expired. Please sign in again.';
        } else if (code == 'email_delivery_failed') {
          message = detail == null || detail.isEmpty
              ? 'The email provider failed to send the message.'
              : 'The email provider failed to send the message: $detail';
        }
      } catch (_) {
        final trimmed = response.body.trim();
        if (trimmed.isNotEmpty) {
          message = '$message Response: $trimmed';
        }
      }

      throw Exception(message);
    }

    throw Exception(
      lastMessage ??
          'Could not find a working verification endpoint. Tried: ${triedUrls.join(', ')}',
    );
  }

  Future<StudentEmailVerificationState> getVerificationState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const StudentEmailVerificationState(isVerified: false);
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return const StudentEmailVerificationState(isVerified: false);
    }

    final data = doc.data() ?? {};
    final isVerified = data['studentEmailVerified'] == true;
    final email = data['studentEmail']?.toString();

    return StudentEmailVerificationState(
      isVerified: isVerified,
      studentEmail: email,
    );
  }
}
