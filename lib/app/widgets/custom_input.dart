import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon; // For Register/Instructor (Left side)
  final IconData? suffixIcon; // For Login (Right side)
  final bool isPassword;
  final bool isDropdown;      // For Register Dropdowns
  final TextEditingController? controller;

  const CustomInput({
    super.key, 
    required this.hint, 
    this.prefixIcon,
    this.suffixIcon, 
    this.isPassword = false,
    this.isDropdown = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7), // Light Grey
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          
          // Logic to show icon on Left OR Right depending on what you pass
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: const Color(0xFF003B73), size: 22) 
              : null,
          
          suffixIcon: suffixIcon != null 
              ? Icon(suffixIcon, color: const Color(0xFF94A3B8)) 
              : (isDropdown 
                  ? const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)) 
                  : (isPassword ? const Icon(Icons.visibility_off_outlined, color: Color(0xFF94A3B8)) : null)
                ),
        ),
      ),
    );
  }
}