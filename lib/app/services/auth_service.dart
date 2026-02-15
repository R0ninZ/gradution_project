import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/student_entity.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // =========================================================
  // CURRENT USER
  // =========================================================

  User? get currentUser => _client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  // =========================================================
  // SIGN UP + INSERT STUDENT PROFILE
  // =========================================================

  Future<void> signUpStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required int universityYear,
    required String track,
  }) async {
    try {
      // 1️⃣ Create Auth user
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;

      if (user == null) {
        throw Exception('Auth user creation failed');
      }

      // 2️⃣ Insert into students table
      await _client.from('students').insert({
        'id': user.id, // UUID from auth.users
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'student_id': studentId,
        'university_year': universityYear,
        'track': track,
      });

    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // =========================================================
  // SIGN IN
  // =========================================================

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception('Invalid credentials');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // =========================================================
  // FETCH CURRENT STUDENT PROFILE
  // =========================================================

  Future<StudentEntity> getCurrentStudentProfile() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final data = await _client
        .from('students')
        .select()
        .eq('id', user.id)
        .single();

    return StudentEntity.fromMap(data);
  }

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================

  Future<void> sendResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // =========================================================
  // RESET PASSWORD
  // =========================================================

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =========================================================
  // SESSION CHECK (AUTO LOGIN)
  // =========================================================

  Future<bool> hasActiveSession() async {
    final session = _client.auth.currentSession;
    return session != null;
  }
}
