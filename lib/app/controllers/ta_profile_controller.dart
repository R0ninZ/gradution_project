import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gradution_project/app/controllers/ta_home_controller.dart';

class TaProfileController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  bool isLoading = true;
  bool isSaving = false;

  String firstName = '';
  String lastName = '';
  String email = '';
  String? avatarUrl;

  String get fullName => '$firstName $lastName'.trim();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading = true;
      update();

      final user = _supabase.auth.currentUser;
      if (user == null) { Get.offAllNamed('/ta-login'); return; }

      final data = await _supabase
          .from('teaching_assistants')
          .select('first_name, last_name, avatar_url')
          .eq('id', user.id)
          .single();

      firstName = data['first_name'] ?? '';
      lastName = data['last_name'] ?? '';
      email = user.email ?? '';

      final rawUrl = data['avatar_url'] as String?;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        final base = rawUrl.contains('?') ? rawUrl.split('?').first : rawUrl;
        avatarUrl = '$base?t=${DateTime.now().millisecondsSinceEpoch}';
      } else {
        avatarUrl = null;
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Could not load profile. Check your internet.', isError: true);
      } else {
        _snack('Error', 'Failed to load profile. Please try again.', isError: true);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> saveChanges({
    required String newFirstName,
    required String newLastName,
  }) async {
    if (newFirstName.trim().isEmpty || newLastName.trim().isEmpty) {
      _snack('Missing Name', 'First and last name cannot be empty.', isError: true);
      return;
    }
    if (!RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]{2,}$").hasMatch(newFirstName.trim())) {
      _snack('Invalid First Name', 'Name must contain only letters (min. 2 characters).', isError: true);
      return;
    }
    if (!RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]{2,}$").hasMatch(newLastName.trim())) {
      _snack('Invalid Last Name', 'Name must contain only letters (min. 2 characters).', isError: true);
      return;
    }

    try {
      isSaving = true;
      update();

      final user = _supabase.auth.currentUser;
      if (user == null) { Get.offAllNamed('/ta-login'); return; }

      await _supabase.from('teaching_assistants').update({
        'first_name': newFirstName.trim(),
        'last_name': newLastName.trim(),
      }).eq('id', user.id);

      firstName = newFirstName.trim();
      lastName = newLastName.trim();
      _syncToHome();

      Get.back();
      _snack('Saved ✓', 'Your profile has been updated.', isError: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Could not save changes. Check your internet.', isError: true);
      } else {
        _snack('Save Failed', 'Something went wrong. Please try again.', isError: true);
      }
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> pickAndUploadAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      isSaving = true;
      update();

      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
      final path = 'ta_avatars/${user.id}/avatar';

      try { await _supabase.storage.from('avatars').remove([path]); } catch (_) {}

      await _supabase.storage.from('avatars').uploadBinary(
        path, bytes,
        fileOptions: FileOptions(upsert: true, contentType: mime),
      );

      final baseUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      final cacheBustedUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      await _supabase.from('teaching_assistants').update({'avatar_url': cacheBustedUrl}).eq('id', user.id);

      avatarUrl = cacheBustedUrl;
      _syncToHome();
      _snack('Photo Updated ✓', 'Your profile picture has been updated.', isError: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        _snack('No Connection', 'Could not upload image. Check your internet.', isError: true);
      } else {
        _snack('Upload Failed', 'Could not upload image. Please try again.', isError: true);
      }
    } finally {
      isSaving = false;
      update();
    }
  }

  void _syncToHome() {
    try {
      final home = Get.find<TaHomeController>();
      home.firstName = firstName;
      home.fullName = fullName;
      home.avatarUrl = avatarUrl;
      home.update();
    } catch (_) {}
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
}
