import 'package:flutter/material.dart';

class BottomOneButtonSmall extends StatelessWidget {
  final String first;
  final void Function()? onFirstButtonClick; // 새로운 콜백 함수 추가

  const BottomOneButtonSmall({
    Key? key,
    required this.first,
    this.onFirstButtonClick, // 콜백 함수를 생성자에 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OneButtonDialog(
      width: 110,
      first: first,
      onFirstButtonClick: onFirstButtonClick, // 콜백 함수 전달
    );
  }
}

class OneButtonDialog extends StatelessWidget {
  final double? width;
  final String first;
  final void Function()? onFirstButtonClick; // 새로운 콜백 함수 추가

  const OneButtonDialog({
    Key? key,
    this.width,
    required this.first,
    this.onFirstButtonClick, // 콜백 함수를 생성자에 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          first,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: width ?? double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (onFirstButtonClick != null) {
                // 콜백 함수가 null이 아닌 경우 실행
                onFirstButtonClick!();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xff212121),
            ),
            child: const Text(
              "확인",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
