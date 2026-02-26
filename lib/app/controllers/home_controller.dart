import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  String firstName = '';
  String fullName = '';
  String studentId = '';
  String? avatarUrl;
  bool isLoading = true;
  bool hasFullName = false;

  @override
  void onInit() {
    super.onInit();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      final data = await _client
          .from('students')
          .select('first_name, last_name, student_id, avatar_url, full_name')
          .eq('id', user.id)
          .single();

      firstName = data['first_name'] ?? '';
      fullName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
      studentId = data['student_id'] ?? '';
      avatarUrl = data['avatar_url'];

      final dbFullName = data['full_name'];
      hasFullName = dbFullName != null && (dbFullName as String).trim().isNotEmpty;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        Get.snackbar(
          'No Connection',
          'Could not load your data. Check your internet and try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFF5252),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      }
      // Silently fail for other errors — home screen still shows
    } finally {
      isLoading = false;
      update();
    }
  }

  void goToChatbot() {
    Get.toNamed('/ai-buddy-intro', arguments: {'returnRoute': '/home'});
  }
}
