import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  BASE URL CONFIG
//  • Android emulator  → 10.0.2.2 maps to your machine's localhost
//  • iOS simulator     → localhost works directly
//  • Physical device   → use your ngrok URL or local network IP
// ─────────────────────────────────────────────────────────────────────────────
// const String _kBaseUrl = 'http://10.0.2.2:8000';     // Android emulator
const String _kBaseUrl = 'http://13.49.107.122:8000';         // Flutter Web / Chrome
// const String _kBaseUrl = 'https://xxxx.ngrok.io';     // ngrok / real device

// ─────────────────────────────────────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Controller
// ─────────────────────────────────────────────────────────────────────────────

class AIBuddyController extends GetxController {
  final _supabase = Supabase.instance.client;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  // Uses .obs so the view reacts to every push/clear without full rebuilds
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isFetchingId = true.obs; // true while we fetch student_id on init

  /// The academic student ID (e.g. "22030094") — what the API expects.
  /// This is the `student_id` column in the `students` table, NOT the UUID.
  String _studentId = '';

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _fetchStudentId();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ── Fetch the student_id string from Supabase ─────────────────────────────

  Future<void> _fetchStudentId() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      final data = await _supabase
          .from('students')
          .select('student_id')
          .eq('id', user.id)
          .single();

      _studentId = (data['student_id'] as String?) ?? '';
    } catch (e) {
      _showSnack('Error', 'Could not load your profile. Please try again.', isError: true);
    } finally {
      isFetchingId.value = false;
    }
  }

  // ── Send a message ────────────────────────────────────────────────────────

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading.value || isFetchingId.value) return;

    if (_studentId.isEmpty) {
      _showSnack('Not Ready', 'Still loading your profile. Please wait.', isError: true);
      return;
    }

    textController.clear();
    messages.add(ChatMessage(text: text, isUser: true));
    _scrollToBottom();
    isLoading.value = true;

    try {
      final response = await http
          .post(
            Uri.parse('$_kBaseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'student_id': _studentId, 'message': text}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = (data['response'] as String?) ?? '—';
        messages.add(ChatMessage(text: reply, isUser: false));
      } else {
        messages.add(ChatMessage(
          text: 'Server error (${response.statusCode}). Please try again.',
          isUser: false,
          isError: true,
        ));
      }
    } on Exception catch (e) {
      messages.add(ChatMessage(
        text: 'Could not reach the server. Check your connection.',
        isUser: false,
        isError: true,
      ));
      debugPrint('[AIBuddy] sendMessage error: $e');
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  // ── Clear history (UI + server) ───────────────────────────────────────────

  Future<void> clearHistory() async {
    messages.clear(); // instant UI clear

    if (_studentId.isEmpty) return;

    try {
      await http.post(
        Uri.parse('$_kBaseUrl/clear-history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': _studentId}),
      );
    } on Exception catch (e) {
      debugPrint('[AIBuddy] clear-history error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnack(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
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