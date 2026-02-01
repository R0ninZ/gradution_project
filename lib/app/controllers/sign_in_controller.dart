import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class SignInController extends GetxController {
  final emailOrIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  final AuthService _auth = Get.find();

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  Future<void> signIn() async {
    if (emailOrIdController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading = true;
      update();

      // 🔐 SIGN IN
      await _auth.signIn(
        email: emailOrIdController.text.trim(),
        password: passwordController.text,
      );

      // ✅ SAFELY GET USER
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Login failed. Please try again.');
      }

      // 🔴 EMAIL VERIFICATION CHECK
      if (user.emailConfirmedAt == null) {
        Get.snackbar(
          'Email not verified',
          'Please verify your email first',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // ✅ SUCCESS
      Get.offAllNamed('/home');

    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void goToSignUp() {
    Get.toNamed('/register');
  }
}
