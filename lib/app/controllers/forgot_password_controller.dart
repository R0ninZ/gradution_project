import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  bool isLoading = false;

  final AuthService _auth = Get.find();

  Future<void> submit() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading = true;
      update();

      await _auth.sendResetEmail(emailController.text.trim());

      Get.snackbar(
        'Email sent',
        'Check your email to reset password',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.toNamed('/verify-email', arguments: emailController.text.trim());

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void backToLogin() {
    Get.back();
  }
}
