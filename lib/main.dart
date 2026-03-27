import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';
import 'viewmodels/loan_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/feedback_viewmodel.dart';
import 'viewmodels/support_viewmodel.dart';
import 'viewmodels/language_viewmodel.dart';
import 'viewmodels/student_loan_viewmodel.dart';
import 'services/local_storage_service.dart';
import 'services/push_notification_service.dart';
import 'services/vnpt_ekyc_service.dart';
import 'services/vnpt_credentials_manager.dart';
import 'onboarding/splash_screen.dart';
import 'loan/step3_personal_info.dart';
import 'loan/step4_offer_calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler — prevents framework errors from killing the app
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log the error but DO NOT rethrow — keep the app alive
    print('[FlutterError] ${details.exceptionAsString()}');
  };

  // Initialize local storage
  await LocalStorageService.init();

  if (kDebugMode) {
    await LocalStorageService.clearTosAccepted();
  }

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize VNPT eKYC service — non-fatal: if this fails, eKYC features
  // will show an error when used, but the rest of the app still loads.
  try {
    await VnptEkycService.initialize();
  } catch (e) {
    if (e.toString().contains('HẾT HẠN') || e.toString().contains('expired')) {
      print('[VNPT] Token expired, clearing cache and retrying from .env...');
      try {
        await VnptCredentialsManager.clearCredentials();
        await VnptEkycService.initialize();
      } catch (retryError) {
        // Still failed after retry — warn but continue app startup
        print('[VNPT] Retry failed: $retryError. eKYC will be unavailable.');
      }
    } else {
      // Any other error (missing credentials, parse error, etc.) — warn and continue
      print(
        '[VNPT] Initialization failed: $e. eKYC features will be unavailable.',
      );
    }
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize local storage (called again after Firebase in case of dependency)
  await LocalStorageService.init();

  // Initialize FCM and local notification handling
  await PushNotificationService().initialize();

  runApp(const VietCreditApp());
}

class VietCreditApp extends StatelessWidget {
  const VietCreditApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => LoanViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => FeedbackViewModel()),
        ChangeNotifierProvider(create: (_) => SupportViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => StudentLoanViewModel()),
      ],
      child: Consumer<LanguageViewModel>(
        builder: (context, languageVm, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: languageVm.locale,
          supportedLocales: const [Locale('en'), Locale('vi')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryGreen,
              primary: primaryGreen,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryGreen, width: 1.4),
              ),
              labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/step3_personal_info': (context) =>
              const Step3PersonalInfoPage(),
            '/step3_additional_info': (context) =>
                const Step3PersonalInfoPage(),
            '/step4_offer_calculator': (context) =>
                const Step4OfferCalculatorPage(),
          },
        ),
      ),
    );
  }
}
