import 'package:flutter/material.dart';

class SuffixTextfield extends StatelessWidget {
  final String? hintText;
  final String buttonText;
  final TextEditingController controller;
  final void Function() onPressed;

  const SuffixTextfield({
    super.key,
    required this.hintText,
    required this.buttonText,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: TextButton(
          onPressed: () => onPressed(),
          child: Text(buttonText),
        ),
        /*
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: TextButton(
            onPressed: () => onPressed(controller.text),
            child: const Text(${widget.buttonText}),
          ),
        ),
        */
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
