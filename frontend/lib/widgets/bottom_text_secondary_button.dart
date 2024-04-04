import 'package:flutter/material.dart';

class BottomTextSecondaryButton extends StatelessWidget {
  final String text;
  final Function handlePressed;

  const BottomTextSecondaryButton({
    super.key,
    required this.text,
    required this.handlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      width: 370,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          handlePressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xe7e7ebff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
