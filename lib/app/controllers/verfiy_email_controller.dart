import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailController extends GetxController {
  final int length = 6;

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  
  String? email;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments as String?;
    controllers = List.generate(length, (_) => TextEditingController());
    focusNodes = List.generate(length, (_) => FocusNode());

    for (final node in focusNodes) {
      node.addListener(update);
    }
  }

  void onCodeChanged(String value, int index) {
    if (value.isEmpty) return;

    final digit = value.characters.last;
    controllers[index].text = digit;
    controllers[index].selection =
        const TextSelection.collapsed(offset: 1);

    if (index < length - 1) {
      focusNodes[index + 1].requestFocus();
    }

    update();
  }

  Future<void> submit() async {
    final code = controllers.map((c) => c.text).join();

    if (code.length != length) {
      Get.snackbar(
        'Error',
        'Please enter all 6 digits',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (email == null) {
      Get.snackbar('Error', 'Email address missing. Please try again.');
      return;
    }

    try {
      isLoading = true;
      update();

      // Verify the OTP to log the user in
      await Supabase.instance.client.auth.verifyOTP(
        token: code,
        type: OtpType.recovery,
        email: email,
      );

      Get.toNamed('/reset-password');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid code: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> resendCode() async {
    if (email != null) {
      await Supabase.instance.client.auth.resetPasswordForEmail(email!);
      Get.snackbar('Code Sent', 'Code resent to your email');
    }
  }

  @override
  void onClose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
