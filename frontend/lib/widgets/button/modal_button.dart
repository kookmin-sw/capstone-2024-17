import 'package:flutter/material.dart';

class ModalButton extends StatelessWidget {
  final String text;
  final Function handlePressed;
  final Color buttonColor; // 선택적 매개변수로 변경

  const ModalButton({
    required this.text,
    required this.handlePressed,
    this.buttonColor = const Color(0xff212121), // 기본값 설정
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
          backgroundColor: buttonColor,
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
