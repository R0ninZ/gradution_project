import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF063C63),
      ),
      body: const Center(
        child: Text(
          'Login Screen Placeholder',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
