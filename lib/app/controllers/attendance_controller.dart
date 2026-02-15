import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  bool isLoading = true;
  String firstName = '';
  String lastName = '';
  String studentId = '';
  
  String get fullName => '$firstName $lastName';

  @override
  void onInit() {
    super.onInit();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      isLoading = true;
      update();

      // Get current user ID
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Fetch student data from Supabase
      // Note: 'id' in students table matches auth user id
      final response = await _supabase
          .from('students')
          .select('first_name, last_name, student_id')
          .eq('id', userId)
          .single();

      firstName = response['first_name'] ?? '';
      lastName = response['last_name'] ?? '';
      studentId = response['student_id'] ?? '';

      isLoading = false;
      update();
      
    } catch (e) {
      isLoading = false;
      update();
      
      Get.snackbar(
        'Error',
        'Failed to load student data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}