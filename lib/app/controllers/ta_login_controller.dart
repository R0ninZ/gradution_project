import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaLoginController extends GetxController {
  final _supabase = Supabase.instance.client;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    update();
  }

  Future<void> signIn() async {
    if (isLoading) return;

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty && password.isEmpty) {
      _snack('Empty Fields', 'Please enter your email and password.', isError: true);
      return;
    }
    if (email.isEmpty) {
      _snack('Missing Email', 'Please enter your email address.', isError: true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _snack('Invalid Email', 'Please enter a valid email address.', isError: true);
      return;
    }
    if (password.isEmpty) {
      _snack('Missing Password', 'Please enter your password.', isError: true);
      return;
    }

    try {
      isLoading = true;
      update();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Login failed. Please try again.');

      final ta = await _supabase
          .from('teaching_assistants')
          .select('id, first_name, last_name')
          .eq('id', user.id)
          .maybeSingle();

      if (ta == null) {
        await _supabase.auth.signOut();
        _snack('Not a TA Account', 'No teaching assistant account found for this email.', isError: true);
        return;
      }

      Get.put(TaSessionController()
        ..setSession(
          id: ta['id'],
          email: email,
          firstName: ta['first_name'] ?? '',
          lastName: ta['last_name'] ?? '',
        ));

      Get.offAllNamed('/ta-home');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid login') || msg.contains('invalid credentials') || msg.contains('wrong password')) {
        _snack('Incorrect Password', 'The email or password you entered is wrong.', isError: true);
      } else if (msg.contains('user not found') || msg.contains('no user')) {
        _snack('Account Not Found', 'No account found with this email.', isError: true);
      } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Check your internet connection and try again.', isError: true);
      } else if (msg.contains('too many') || msg.contains('rate limit')) {
        _snack('Too Many Attempts', 'Please wait a moment before trying again.', isError: true);
      } else {
        _snack('Login Failed', 'Something went wrong. Please try again.', isError: true);
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
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

// ── Lightweight TA session holder ─────────────────────────────────────────────
class TaSessionController extends GetxController {
  String id = '';
  String email = '';
  String firstName = '';
  String lastName = '';

  String get fullName => '$firstName $lastName';

  void setSession({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
  }) {
    this.id = id;
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
    update();
  }

  void clear() {
    id = email = firstName = lastName = '';
    update();
  }
}
