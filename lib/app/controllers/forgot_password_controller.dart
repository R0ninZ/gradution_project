import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  bool isLoading = false;

  final AuthService _auth = Get.find();

  Future<void> submit() async {
    if (isLoading) return;

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _snack('Missing Email', 'Please enter your email address.', isError: true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _snack('Invalid Email', 'Please enter a valid email address.', isError: true);
      return;
    }

    try {
      isLoading = true;
      update();

      await _auth.sendResetEmail(email);

      _snack('Email Sent ✓', 'Check your inbox for the reset code.', isError: false);
      Get.toNamed('/verify-email', arguments: email);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('user not found') || msg.contains('no user')) {
        _snack('Email Not Found', 'No account is registered with this email.', isError: true);
      } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else if (msg.contains('rate limit') || msg.contains('too many')) {
        _snack('Too Many Requests', 'Please wait a minute before requesting another code.', isError: true);
      } else {
        _snack('Something Went Wrong', 'Could not send the reset email. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  void backToLogin() => Get.back();

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
    emailController.dispose();
    super.onClose();
  }
}
