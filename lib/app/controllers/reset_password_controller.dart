import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ResetPasswordController extends GetxController {
  // ================= TEXT CONTROLLERS =================
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ================= UI STATE =================
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  // ================= PASSWORD VALIDATION =================
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

  // ================= UI HELPERS =================
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    update();
  }

  // ================= PASSWORD VALIDATION =================
  void _validatePassword() {
    final password = newPasswordController.text;

    hasMinLength = password.length >= 8;
    hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    hasLowerCase = password.contains(RegExp(r'[a-z]'));
    hasDigit = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    update();
  }

  bool get isPasswordValid =>
      hasMinLength &&
      hasUpperCase &&
      hasLowerCase &&
      hasDigit &&
      hasSpecialChar;

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!isPasswordValid) return;

    if (newPasswordController.text !=
        confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading = true;
      update();

      await _auth.updatePassword(newPasswordController.text);

      Get.snackbar(
        'Success',
        'Password reset successfully!',
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );

      // ✅ BACK TO LOGIN
      Get.offAllNamed('/login');

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
}
