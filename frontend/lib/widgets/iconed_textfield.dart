import 'package:flutter/material.dart';

class IconedTextfield extends StatelessWidget {
  final Icon? icon;
  final String hintText;
  final TextEditingController controller;
  final bool isSecret;

  const IconedTextfield({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    required this.isSecret,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffff6c3e)),
          borderRadius: BorderRadius.circular(15),
        ),
        hintText: hintText,
      ),
      obscureText: isSecret,
    );
  }
}
