import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaSignUpController extends GetxController {
  final _supabase = Supabase.instance.client;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  int currentStep = 1;

  String? _registeredTaId;

  void togglePassword() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void toggleConfirmPassword() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    update();
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  bool _isValidName(String name) =>
      RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]{2,}$").hasMatch(name.trim());

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());

  String? _validateStep1() {
    final fn = firstNameCtrl.text.trim();
    final ln = lastNameCtrl.text.trim();
    final em = emailCtrl.text.trim();
    final pw = passwordCtrl.text;
    final cf = confirmPasswordCtrl.text;

    if (fn.isEmpty || ln.isEmpty || em.isEmpty || pw.isEmpty || cf.isEmpty) {
      return 'Please fill in all fields.';
    }
    if (!_isValidName(fn)) return 'First name must contain only letters (min. 2 characters).';
    if (!_isValidName(ln)) return 'Last name must contain only letters (min. 2 characters).';
    if (!_isValidEmail(em)) return 'Please enter a valid email address.';
    if (pw.length < 8) return 'Password must be at least 8 characters.';
    if (!pw.contains(RegExp(r'[A-Z]'))) return 'Password must contain at least one uppercase letter.';
    if (!pw.contains(RegExp(r'[a-z]'))) return 'Password must contain at least one lowercase letter.';
    if (!pw.contains(RegExp(r'[0-9]'))) return 'Password must contain at least one number.';
    if (!pw.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    if (pw != cf) return 'Passwords do not match.';
    return null;
  }

  // ── STEP 1: Register ───────────────────────────────────────────────────────

  Future<void> submitRegistration() async {
    if (isLoading) return;

    final error = _validateStep1();
    if (error != null) { _snack('Invalid Input', error, isError: true); return; }

    try {
      isLoading = true;
      update();

      final authResponse = await _supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );

      final user = authResponse.user;
      if (user == null) throw Exception('Registration failed. Please try again.');

      final inserted = await _supabase
          .from('teaching_assistants')
          .insert({
            'id': user.id,
            'email': emailCtrl.text.trim(),
            'first_name': firstNameCtrl.text.trim(),
            'last_name': lastNameCtrl.text.trim(),
          })
          .select('id')
          .single();

      _registeredTaId = inserted['id'];
      currentStep = 2;
    } catch (e) {
      await _cleanupAuthUser();
      final msg = e.toString().toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        _snack('Email Already Used', 'This email is already registered. Try signing in instead.', isError: true);
      } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else {
        _snack('Sign Up Failed', 'Something went wrong. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  // ── STEP 2: Verify code ────────────────────────────────────────────────────

  Future<void> verifyCode() async {
    if (isLoading) return;

    final code = codeCtrl.text.trim().toUpperCase();

    if (code.isEmpty) {
      _snack('Missing Code', 'Please enter the activation code.', isError: true);
      return;
    }
    if (code.length != 6) {
      _snack('Invalid Code', 'The code must be exactly 6 characters.', isError: true);
      return;
    }
    if (_registeredTaId == null) {
      _snack('Session Lost', 'Registration session expired. Please sign up again.', isError: true);
      return;
    }

    try {
      isLoading = true;
      update();

      final result = await _supabase
          .from('ta_registration_codes')
          .select('id, expires_at, used')
          .eq('ta_id', _registeredTaId!)
          .eq('code', code)
          .eq('used', false)
          .maybeSingle();

      if (result == null) {
        _snack('Invalid Code', 'This code is incorrect or already been used.', isError: true);
        return;
      }

      final expiresAt = DateTime.parse(result['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        _snack('Code Expired', 'This code has expired. Ask your administrator for a new one.', isError: true);
        return;
      }

      await _supabase
          .from('ta_registration_codes')
          .update({'used': true}).eq('id', result['id']);

      await _supabase.auth.signOut();

      _snack('Account Activated! 🎉', 'Your TA account is ready. Please sign in.', isError: false);
      Get.offAllNamed('/ta-login');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else {
        _snack('Verification Failed', 'Could not verify the code. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  // ── Abandon ────────────────────────────────────────────────────────────────

  Future<void> abandonRegistration() async {
    if (_registeredTaId == null) return;
    try {
      await _supabase.from('teaching_assistants').delete().eq('id', _registeredTaId!);
      await _cleanupAuthUser();
    } catch (_) {}
  }

  Future<void> _cleanupAuthUser() async {
    try { await _supabase.auth.signOut(); } catch (_) {}
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
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    codeCtrl.dispose();
    super.onClose();
  }
}
