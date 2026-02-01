import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  User? get currentUser => _client.auth.currentUser;

  // ================= SIGN UP =================
  Future<void> signUpStudent({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String studentId,
  required int universityYear,
  required String track,
}) async {
  final res = await _client.auth.signUp(
    email: email,
    password: password,
  );

  final user = res.user;
  if (user == null) {
    throw Exception('Failed to create user');
  }

  await _client.from('students').insert({
    'id': user.id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'student_id': studentId,
    'university_year': universityYear,
    'track': track,
  });
}


  // ================= SIGN IN =================
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw AuthException('Invalid credentials');
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> sendResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ================= RESET PASSWORD =================
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ================= LOGOUT =================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
