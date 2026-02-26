import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentModel {
  final String firstName;
  final String lastName;
  final String track;
  final int universityYear;
  final String? linkedin;
  final String? avatarUrl;

  StudentModel({
    required this.firstName,
    required this.lastName,
    required this.track,
    required this.universityYear,
    this.linkedin,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      track: map['track'] ?? '',
      universityYear: map['university_year'] ?? 1,
      linkedin: map['linkedin'],
      avatarUrl: map['avatar_url'],
    );
  }
}

class CommunityController extends GetxController {
  final _supabase = Supabase.instance.client;

  bool isLoading = true;

  List<StudentModel> _allStudents = [];
  List<StudentModel> filteredStudents = [];

  String searchQuery = '';
  String? selectedTrack;
  int? selectedYear;

  final List<String> tracks = ['AIM', 'SAD', 'DAS'];
  final List<int> years = [1, 2, 3, 4];

  int get activeFilterCount =>
      (selectedTrack != null ? 1 : 0) + (selectedYear != null ? 1 : 0);

  bool get hasActiveFilters =>
      selectedTrack != null || selectedYear != null || searchQuery.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      isLoading = true;
      update();

      final currentUserId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('students')
          .select('first_name, last_name, track, university_year, linkedin, avatar_url')
          .neq('id', currentUserId ?? '');

      _allStudents = (response as List).map((e) => StudentModel.fromMap(e)).toList();
      _applyFilters();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
        Get.snackbar(
          'No Connection',
          'Could not load community. Check your internet and try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFF5252),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      }
      // Silently show empty list for other errors
    } finally {
      isLoading = false;
      update();
    }
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    _applyFilters();
    update();
  }

  void setTrackFilter(String? track) {
    selectedTrack = track;
    _applyFilters();
    update();
  }

  void setYearFilter(int? year) {
    selectedYear = year;
    _applyFilters();
    update();
  }

  void clearFilters() {
    selectedTrack = null;
    selectedYear = null;
    searchQuery = '';
    _applyFilters();
    update();
  }

  void _applyFilters() {
    filteredStudents = _allStudents.where((s) {
      final matchesSearch = searchQuery.isEmpty ||
          s.fullName.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesTrack = selectedTrack == null || s.track == selectedTrack;
      final matchesYear = selectedYear == null || s.universityYear == selectedYear;
      return matchesSearch && matchesTrack && matchesYear;
    }).toList();
  }
}
