import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/ai_buddy_controller.dart';
import 'package:gradution_project/app/controllers/admin_controller.dart';
import 'package:gradution_project/app/controllers/community_controller.dart';
import 'package:gradution_project/app/controllers/forgot_password_controller.dart';
import 'package:gradution_project/app/controllers/home_controller.dart';
import 'package:gradution_project/app/controllers/reset_password_controller.dart';
import 'package:gradution_project/app/controllers/settings_controller.dart';
import 'package:gradution_project/app/controllers/sign_in_controller.dart';
import 'package:gradution_project/app/controllers/sign_up_controller.dart';
import 'package:gradution_project/app/controllers/splash_controller.dart';
import 'package:gradution_project/app/controllers/ta_home_controller.dart';
import 'package:gradution_project/app/controllers/ta_login_controller.dart';
import 'package:gradution_project/app/controllers/ta_profile_controller.dart';
import 'package:gradution_project/app/controllers/ta_sign_up_controller.dart';
import 'package:gradution_project/app/controllers/verfiy_email_controller.dart';
import 'package:gradution_project/app/services/auth_service.dart';
import 'package:gradution_project/app/services/language_service.dart';
import 'package:gradution_project/app/translations/app_translations.dart';
import 'package:gradution_project/app/views/admin_views.dart';
import 'package:gradution_project/app/views/ai_buddy_intro_view.dart';
import 'package:gradution_project/app/views/ai_buddy_view.dart';
import 'package:gradution_project/app/controllers/profile_controller.dart';
import 'package:gradution_project/app/views/attendance_scanner_view.dart';
import 'package:gradution_project/app/views/community_view.dart';
import 'package:gradution_project/app/views/edit_profile_view.dart';
import 'package:gradution_project/app/views/profile_view.dart';
import 'package:gradution_project/app/views/forgot_password_view.dart';
import 'package:gradution_project/app/views/home_view.dart';
import 'package:gradution_project/app/views/reset_password_view.dart';
import 'package:gradution_project/app/views/saved_sessions_view.dart';
import 'package:gradution_project/app/views/sign_in_view.dart';
import 'package:gradution_project/app/views/sign_up_view.dart';
import 'package:gradution_project/app/views/splash_view.dart';
import 'package:gradution_project/app/views/ta_edit_profile_view.dart';
import 'package:gradution_project/app/views/ta_home_view.dart';
import 'package:gradution_project/app/views/ta_login_view.dart';
import 'package:gradution_project/app/views/ta_profile_view.dart';
import 'package:gradution_project/app/views/ta_sign_up_view.dart';
import 'package:gradution_project/app/views/verfiy_email_view.dart';
import 'package:gradution_project/app/views/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load saved preferences BEFORE runApp so locale & theme never reset ──
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('selected_language') ?? 'en';
  final savedDark = prefs.getBool('is_dark_mode') ?? false;

  final initialLocale =
      savedLang == 'ar' ? const Locale('ar', 'AR') : const Locale('en', 'US');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://fnquuvxprieyvpmlyfzb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucXV1dnhwcmlleXZwbWx5ZnpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMDQ5MzMsImV4cCI6MjA3NTg4MDkzM30.5t0KAiiY_QhH4wdcAYf52BxqWflIfy7jRcRuWnZCbHE',
  );

  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<SplashController>(SplashController(), permanent: true);
  Get.put<LanguageService>(LanguageService(), permanent: true);

  // ── SettingsController is permanent so theme & language survive navigation ──
  final settingsCtrl = Get.put<SettingsController>(
    SettingsController(),
    permanent: true,
  );
  // Apply saved theme immediately before first frame
  settingsCtrl.applyThemeOnStartup(savedDark);

  runApp(MyApp(initialLocale: initialLocale, initialDark: savedDark));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  final bool initialDark;

  const MyApp({
    super.key,
    required this.initialLocale,
    required this.initialDark,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: initialDark ? ThemeMode.dark : ThemeMode.light,

      // ── Localization ────────────────────────────────────────────────────
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      builder: (context, child) {
        return Obx(() {
          final lang = Get.find<LanguageService>();
          return Directionality(
            textDirection: lang.textDirection,
            child: child!,
          );
        });
      },

      initialRoute: '/splash',
      getPages: [
        // ── Student / Admin shared login ───────────────────────────────────
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut<SplashController>(
              () => SplashController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/login',
          page: () => const SignInView(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 600),
          binding: BindingsBuilder(
            () => Get.lazyPut<SignInController>(
              () => SignInController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/register',
          page: () => const SignUpView(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 600),
          binding: BindingsBuilder(
            () => Get.lazyPut<SignUpController>(
              () => SignUpController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 400),
          binding: BindingsBuilder(
            () => Get.lazyPut<ForgotPasswordController>(
              () => ForgotPasswordController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/verify-email',
          page: () => const VerifyEmailView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 400),
          binding: BindingsBuilder(
            () => Get.lazyPut<VerifyEmailController>(
              () => VerifyEmailController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/reset-password',
          page: () => const ResetPasswordView(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 500),
          binding: BindingsBuilder(
            () => Get.lazyPut<ResetPasswordController>(
              () => ResetPasswordController(),
              fenix: true,
            ),
          ),
        ),

        // ── Student routes ─────────────────────────────────────────────────
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<HomeController>(
              () => HomeController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<ProfileController>(
              () => ProfileController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(name: '/edit-profile', page: () => const EditProfileView()),
        GetPage(
          name: '/community',
          page: () => const CommunityView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<CommunityController>(
              () => CommunityController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(name: '/ai-buddy-intro', page: () => const AIBuddyIntroView()),
        GetPage(
          name: '/ai-buddy',
          page: () => const AIBuddyView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<AIBuddyController>(
              () => AIBuddyController(),
              fenix: true,
            ),
          ),
        ),

        // ── Admin routes ───────────────────────────────────────────────────
        GetPage(
          name: '/admin-home',
          page: () => const AdminHomeView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<AdminController>(
              () => AdminController(),
              fenix: true,
            ),
          ),
        ),

        // ── Settings (shared, accepts isTA via arguments) ──────────────────
        GetPage(
          name: '/settings',
          page: () => const SettingsView(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),

        // ── Teaching Assistant routes ──────────────────────────────────────
        GetPage(
          name: '/ta-login',
          page: () => const TaLoginView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 400),
          binding: BindingsBuilder(
            () => Get.lazyPut<TaLoginController>(
              () => TaLoginController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/ta-signup',
          page: () => const TaSignUpView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 400),
          binding: BindingsBuilder(
            () => Get.lazyPut<TaSignUpController>(
              () => TaSignUpController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/ta-home',
          page: () => const TaHomeView(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 500),
          binding: BindingsBuilder(
            () => Get.lazyPut<TaHomeController>(
              () => TaHomeController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/ta-profile',
          page: () => const TaProfileView(),
          binding: BindingsBuilder(
            () => Get.lazyPut<TaProfileController>(
              () => TaProfileController(),
              fenix: true,
            ),
          ),
        ),
        GetPage(
          name: '/ta-edit-profile',
          page: () => const TaEditProfileView(),
        ),
        GetPage(
          name: '/attendance-scanner',
          page: () => const AttendanceScannerView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 400),
        ),
        GetPage(
          name: '/attendance-sessions',
          page: () => const SavedSessionsView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D3B66),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Colors.white,
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF0D3B66)
              : Colors.grey[400],
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF0D3B66).withOpacity(0.4)
              : Colors.grey[300],
        ),
      ),
      useMaterial3: true,
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3E82F7),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Color(0xFF1E1E2E),
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF3E82F7)
              : Colors.grey[600],
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF3E82F7).withOpacity(0.4)
              : Colors.grey[800],
        ),
      ),
      useMaterial3: true,
    );
  }
}