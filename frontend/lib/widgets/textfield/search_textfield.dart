import 'package:flutter/material.dart';

class SearchTextfield extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final void Function(String) onSearch;

  const SearchTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: IconButton(
            icon: const Icon(Icons.search),
            // color: const Color(0xffff6c3e),
            onPressed: () => onSearch(controller.text),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffff6c3e)),
          borderRadius: BorderRadius.circular(15),
        ),
        hintText: hintText,
      ),
    );
  }
}
