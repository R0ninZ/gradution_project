import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/forgot_password_controller.dart';
import 'package:gradution_project/app/controllers/reset_password_controller.dart';
import 'package:gradution_project/app/controllers/sign_in_controller.dart';
import 'package:gradution_project/app/controllers/sign_up_controller.dart';
import 'package:gradution_project/app/controllers/splash_controller.dart';
import 'package:gradution_project/app/controllers/verfiy_email_controller.dart';
import 'package:gradution_project/app/services/auth_service.dart';
import 'package:gradution_project/app/views/forgot_password_view.dart';
import 'package:gradution_project/app/views/home_view.dart';
import 'package:gradution_project/app/views/reset_password_view.dart';

import 'package:gradution_project/app/views/sign_in_view.dart';
import 'package:gradution_project/app/views/sign_up_view.dart';
import 'package:gradution_project/app/views/splash_view.dart';
import 'package:gradution_project/app/views/verfiy_email_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

   SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  await Supabase.initialize(
    url: 'https://fnquuvxprieyvpmlyfzb.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucXV1dnhwcmlleXZwbWx5ZnpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMDQ5MzMsImV4cCI6MjA3NTg4MDkzM30.5t0KAiiY_QhH4wdcAYf52BxqWflIfy7jRcRuWnZCbHE',
  );
    Get.put<AuthService>(AuthService(), permanent: true);

  runApp(const MyApp());
}
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      
      
       initialRoute: '/splash',
  getPages: [
    GetPage(name: '/home', page: () => const HomeView()),
    GetPage(
      name: '/splash',
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),

    GetPage(
      name: '/login',
      page: () => const SignInView(),
      transition: Transition.fadeIn, // ✅ FINAL PLACE
      transitionDuration: const Duration(milliseconds: 600),
      binding: BindingsBuilder(() {
        Get.put(SignInController());
      }),
    ),

    GetPage(
      name: '/register',
      page: () => const SignUpView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 600),
      binding: BindingsBuilder(() {
        Get.put(SignUpController());
      }),
    ),
    GetPage(
  name: '/forgot-password',
  page: () => const ForgotPasswordView(),
  transition: Transition.rightToLeft,
  transitionDuration: const Duration(milliseconds: 400),
  binding: BindingsBuilder(() {
    Get.put(ForgotPasswordController());
  }),
),
GetPage(
  name: '/verify-email',
  page: () => const VerifyEmailView(),
  transition: Transition.rightToLeft,
  transitionDuration: const Duration(milliseconds: 400),
  binding: BindingsBuilder(() {
    Get.put(VerifyEmailController());
  }),
),GetPage(
  name: '/reset-password',
  page: () => const ResetPasswordView(),
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 500),
  binding: BindingsBuilder(() {
    Get.put(ResetPasswordController());
  }),
),

  ],     
    );
  }
}