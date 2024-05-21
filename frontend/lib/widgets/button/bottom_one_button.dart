import 'package:flutter/material.dart';

class BottomOneButton extends StatelessWidget {
  final double? width;
  final String first;
  final Function handleFirstClick;

  const BottomOneButton({
    super.key,
    this.width, // If width is not specified, it will be null
    required this.first,
    required this.handleFirstClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width ?? double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              handleFirstClick();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xff212121),
            ),
            child: Text(
              first,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
