import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/bottom_two_buttons.dart';
import 'package:frontend/widgets/dialog/yn_dialog.dart';

class YesOrNoDialog extends StatelessWidget {
  final String content;
  final String? firstButton;
  final String? secondButton;
  final Function()? handleFirstClick;
  final Function()? handleSecondClick;

  const YesOrNoDialog({
    this.content = '',
    this.firstButton,
    this.secondButton,
    this.handleFirstClick,
    this.handleSecondClick,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            BottomTwoButtonsSmall(
              first: firstButton ?? '확인',
              second: secondButton ?? '취소',
              handleFirstClick: handleFirstClick ?? () {},
              handleSecondClick: handleSecondClick ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
