import 'package:flutter/material.dart';

class BottomOneButtonSmall extends StatelessWidget {
  final String first;

  const BottomOneButtonSmall({
    Key? key,
    required this.first,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OneButtonDialog(
      width: 110,
      first: first,
    );
  }
}

class OneButtonDialog extends StatelessWidget {
  final double? width;
  final String first;

  const OneButtonDialog({
    super.key,
    this.width, // width 값을 지정하지 않으면 null이 됨
    required this.first,
  });

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
