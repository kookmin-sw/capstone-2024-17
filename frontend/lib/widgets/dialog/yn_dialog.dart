import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/bottom_two_buttons.dart';

class YesOrNoDialog extends StatelessWidget {
  final String content;
  final String firstButton;
  final String secondButton;
  final Function handleFirstClick;
  final Function handleSecondClick;

  const YesOrNoDialog({
    super.key,
    required this.content,
    required this.firstButton,
    required this.secondButton,
    required this.handleFirstClick,
    required this.handleSecondClick,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 300,
        height: 200,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const Expanded(child: SizedBox()),
            BottomTwoButtonsSmall(
              first: "확인",
              second: "취소",
              handleFirstClick: handleFirstClick,
              handleSecondClick: handleSecondClick,
            ),
          ],
        ),
      ),
    );
  }
}
