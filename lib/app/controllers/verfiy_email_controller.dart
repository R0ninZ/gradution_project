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
    if (value.isEmpty) {
      // Handle backspace — move to previous field
      if (index > 0) {
        controllers[index].clear();
        focusNodes[index - 1].requestFocus();
      }
      update();
      return;
    }

    final digit = value.characters.last;
    controllers[index].text = digit;
    controllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus(); // auto-dismiss keyboard on last digit
    }
    update();
  }

  Future<void> submit() async {
    if (isLoading) return;

    final code = controllers.map((c) => c.text.trim()).join();

    if (code.length != length || code.contains(' ')) {
      _snack('Incomplete Code', 'Please enter all 6 digits of the code.', isError: true);
      return;
    }

    if (email == null || email!.isEmpty) {
      _snack('Missing Email', 'Email address is missing. Please go back and try again.', isError: true);
      return;
    }

    try {
      isLoading = true;
      update();

      await Supabase.instance.client.auth.verifyOTP(
        token: code,
        type: OtpType.recovery,
        email: email,
      );

      Get.toNamed('/reset-password');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('expired') || msg.contains('invalid otp')) {
        _snack('Code Expired', 'This code has expired. Tap "Resend code" to get a new one.', isError: true);
      } else if (msg.contains('invalid') || msg.contains('wrong')) {
        _snack('Wrong Code', 'The code you entered is incorrect. Please try again.', isError: true);
      } else if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else {
        _snack('Verification Failed', 'Could not verify the code. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> resendCode() async {
    if (email == null || email!.isEmpty) {
      _snack('Error', 'Email address is missing. Please go back and try again.', isError: true);
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email!);
      _snack('Code Resent ✓', 'A new code has been sent to $email', isError: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('rate limit') || msg.contains('too many')) {
        _snack('Too Many Requests', 'Please wait a minute before requesting another code.', isError: true);
      } else {
        _snack('Failed to Resend', 'Could not resend the code. Please try again.', isError: true);
      }
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
    for (final c in controllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }
}
