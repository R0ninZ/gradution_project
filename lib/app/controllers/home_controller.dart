import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {

  final SupabaseClient _client = Supabase.instance.client;

  String firstName = '';
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    loadStudentName();
  }

  Future<void> loadStudentName() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final data = await _client
          .from('students')
          .select('first_name')
          .eq('id', user.id)
          .single();

      firstName = data['first_name'] ?? '';
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  // ================= NAVIGATION =================

  void goToChatbot() {
    Get.toNamed('/ai-buddy'); // placeholder page
  }
}
