import 'package:flutter/material.dart';

class ModalButton extends StatelessWidget {
  final String text;
  final Function handlePressed;

  const ModalButton({
    super.key,
    required this.text,
    required this.handlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          handlePressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff212121),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
