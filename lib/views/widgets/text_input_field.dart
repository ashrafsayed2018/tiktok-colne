import 'package:flutter/material.dart';
import 'package:tiktok_clone/constants.dart';

class TextInputField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;

  const TextInputField({
    Key? key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final outlineinputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: borderColor),
    );
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 20),
        prefixIcon: Icon(icon),
        enabledBorder: outlineinputBorder,
        focusedBorder: outlineinputBorder,
      ),
    );
  }
}
