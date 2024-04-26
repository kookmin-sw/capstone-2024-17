import 'package:flutter/material.dart';

class ColorTextContainer extends StatelessWidget {
  final String text;

  const ColorTextContainer({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(10),
      width: 370,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xffff916f),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
