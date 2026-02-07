import 'package:flutter/material.dart';
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
import 'services/local_storage_service.dart';
import 'services/vnpt_ekyc_service.dart';
import 'services/vnpt_credentials_manager.dart';
import 'onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  await LocalStorageService.init();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize VNPT eKYC service with credentials from .env
  try {
    await VnptEkycService.initialize();
  } catch (e) {
    // If token is expired, clear cache and reload from .env
    if (e.toString().contains('HẾT HẠN') || e.toString().contains('expired')) {
      print('[VNPT] Token expired, clearing cache and reloading from .env...');
      await VnptCredentialsManager.clearCredentials();
      
      // Retry initialization (will load from .env this time)
      await VnptEkycService.initialize();
    } else {
      rethrow;
    }
  }
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Initialize local storage
  await LocalStorageService.init();
  
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
    );
  }
}
