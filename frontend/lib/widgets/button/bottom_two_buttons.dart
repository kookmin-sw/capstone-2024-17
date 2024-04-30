import 'package:flutter/material.dart';

class BottomTwoButtonsSmall extends StatelessWidget {
  final String first;
  final String second;

  const BottomTwoButtonsSmall({
    super.key,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context) {
    return BottomTwoButtons(width: 110, first: first, second: second);
  }
}

class BottomTwoButtonsMedium extends StatelessWidget {
  final String first;
  final String second;

  const BottomTwoButtonsMedium({
    super.key,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context) {
    return BottomTwoButtons(width: 130, first: first, second: second);
  }
}

class BottomTwoButtons extends StatelessWidget {
  final double width;
  final String first;
  final String second;

  const BottomTwoButtons({
    super.key,
    required this.width,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: width,
          height: 50,
          child: ElevatedButton(
            onPressed: () {},
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
        SizedBox(
          width: width,
          height: 50,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Text(
              second,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        )
      ],
    );
  }
}
