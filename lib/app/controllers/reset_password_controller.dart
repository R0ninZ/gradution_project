import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ResetPasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;

  final AuthService _auth = Get.find();

  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(_validatePassword);
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    update();
  }

  void _validatePassword() {
    final pw = newPasswordController.text;
    hasMinLength = pw.length >= 8;
    hasUpperCase = pw.contains(RegExp(r'[A-Z]'));
    hasLowerCase = pw.contains(RegExp(r'[a-z]'));
    hasDigit = pw.contains(RegExp(r'[0-9]'));
    hasSpecialChar = pw.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    update();
  }

  bool get isPasswordValid =>
      hasMinLength && hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;

  Future<void> submit() async {
    if (isLoading) return;

    if (!isPasswordValid) {
      _snack('Weak Password', 'Your password does not meet all requirements.', isError: true);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _snack('Passwords Do Not Match', 'Make sure both password fields are identical.', isError: true);
      return;
    }

    try {
      isLoading = true;
      update();

      await _auth.updatePassword(newPasswordController.text);

      _snack('Password Reset ✓', 'Your password has been updated. Please sign in.', isError: false);
      Get.offAllNamed('/login');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('session') || msg.contains('expired') || msg.contains('jwt')) {
        _snack('Session Expired', 'Your reset session expired. Please request a new code.', isError: true);
        Get.offAllNamed('/forgot-password');
      } else if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else if (msg.contains('same password') || msg.contains('different from')) {
        _snack('Same Password', 'Please choose a password different from your previous one.', isError: true);
      } else {
        _snack('Reset Failed', 'Could not update your password. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

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
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
