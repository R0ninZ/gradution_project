import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInController extends GetxController {
  final emailOrIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  late final AuthService _auth;
  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  Future<void> signIn() async {
    if (isLoading) return;

    final email = emailOrIdController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      _snack('Empty Fields', 'Please enter your email and password.', isError: true);
      return;
    }
    if (email.isEmpty) {
      _snack('Missing Email', 'Please enter your email address.', isError: true);
      return;
    }
    if (password.isEmpty) {
      _snack('Missing Password', 'Please enter your password.', isError: true);
      return;
    }
    if (!email.contains('@')) {
      _snack('Invalid Email', 'Please enter a valid email address.', isError: true);
      return;
    }

    try {
      isLoading = true;
      update();

      await _auth.signIn(email: email, password: password);

      final user = _auth.currentUser;
      if (user == null) throw Exception('Login failed. Please try again.');

      if (user.emailConfirmedAt == null) {
        await _supabase.auth.signOut();
        _snack('Email Not Verified', 'Please check your inbox and verify your email first.', isError: true);
        return;
      }

      final studentData = await _supabase
          .from('students')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();

      final isAdmin = studentData?['is_admin'] == true;
      Get.offAllNamed(isAdmin ? '/admin-home' : '/home');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid login') || msg.contains('invalid credentials') || msg.contains('wrong password')) {
        _snack('Incorrect Password', 'The email or password you entered is wrong. Please try again.', isError: true);
      } else if (msg.contains('user not found') || msg.contains('no user')) {
        _snack('Account Not Found', 'No account found with this email. Please sign up first.', isError: true);
      } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else if (msg.contains('too many requests') || msg.contains('rate limit')) {
        _snack('Too Many Attempts', 'Too many failed attempts. Please wait a moment and try again.', isError: true);
      } else {
        _snack('Login Failed', 'Something went wrong. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  void goToForgotPassword() => Get.toNamed('/forgot-password');
  void goToSignUp() => Get.toNamed('/register');
  void goToTaLogin() => Get.toNamed('/ta-login');

  void _snack(String title, String message, {required bool isError}) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  @override
  void onClose() {
    emailOrIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
