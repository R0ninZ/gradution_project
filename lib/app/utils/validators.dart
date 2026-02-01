class Validators {
  static String? email(String v) {
    if (v.isEmpty) return 'Email is required';
    if (!v.contains('@')) return 'Invalid email';
    return null;
  }

  static String? password(String v) {
    if (v.length < 8) return 'Min 8 characters';
    return null;
  }

  static String? requiredField(String v) {
    if (v.isEmpty) return 'Required field';
    return null;
  }
}
