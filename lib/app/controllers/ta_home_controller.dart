import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaHomeController extends GetxController {
  final _supabase = Supabase.instance.client;

  bool isLoading = true;
  String fullName = '';
  String firstName = '';
  String? avatarUrl;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      update();

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setDefaults();
        return;
      }

      final data = await _supabase
          .from('teaching_assistants')
          .select('first_name, last_name, avatar_url') // ← fetch avatar too
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        _setDefaults();
        return;
      }

      firstName = data['first_name'] ?? '';
      final lastName = data['last_name'] ?? '';
      fullName = '$firstName $lastName'.trim();

      // Cache-bust so Flutter doesn't serve the old image from memory
      final rawUrl = data['avatar_url'] as String?;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        final base = rawUrl.contains('?') ? rawUrl.split('?').first : rawUrl;
        avatarUrl = '$base?t=${DateTime.now().millisecondsSinceEpoch}';
      } else {
        avatarUrl = null;
      }
    } catch (e) {
      _setDefaults();
    } finally {
      isLoading = false;
      update();
    }
  }

  void _setDefaults() {
    firstName = 'TA';
    fullName = 'Teaching Assistant';
    avatarUrl = null;
  }

  void goToChatbot() => Get.toNamed(
        '/ai-buddy-intro',
        arguments: {'returnRoute': '/ta-home'},
      );
}
