import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController extends GetxController {
  final _supabase = Supabase.instance.client;

  bool isDashboardLoading = false;
  List<Map<String, dynamic>> pendingTAs = [];

  String? generatedCode;
  String? generatedForName;
  DateTime? codeExpiresAt;

  @override
  void onInit() {
    super.onInit();
    loadPendingTAs();
  }

  Future<void> loadPendingTAs() async {
    try {
      isDashboardLoading = true;
      generatedCode = null;
      generatedForName = null;
      codeExpiresAt = null;
      update();

      final data = await _supabase
          .from('teaching_assistants')
          .select('id, first_name, last_name, email')
          .order('id');

      pendingTAs = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Could not load TAs. Check your internet.', isError: true);
      } else {
        _snack('Error', 'Failed to load teaching assistants. Please try again.', isError: true);
      }
    } finally {
      isDashboardLoading = false;
      update();
    }
  }

  Future<void> generateCodeForTA(String taId, String taFullName) async {
    try {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final rand = Random.secure();
      final code = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
      final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 5));

      // Invalidate any previous unused codes for this TA
      await _supabase
          .from('ta_registration_codes')
          .update({'used': true})
          .eq('ta_id', taId)
          .eq('used', false);

      await _supabase.from('ta_registration_codes').insert({
        'ta_id': taId,
        'code': code,
        'expires_at': expiresAt.toIso8601String(),
        'used': false,
      });

      generatedCode = code;
      generatedForName = taFullName;
      codeExpiresAt = expiresAt;
      update();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        _snack('No Connection', 'Could not generate code. Check your internet.', isError: true);
      } else {
        _snack('Failed', 'Could not generate the code. Please try again.', isError: true);
      }
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      Get.offAllNamed('/login');
    } catch (_) {
      Get.offAllNamed('/login'); // Navigate anyway even if signOut fails
    }
  }

  void _snack(String title, String msg, {required bool isError}) {
    Get.snackbar(
      title, msg,
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
}
