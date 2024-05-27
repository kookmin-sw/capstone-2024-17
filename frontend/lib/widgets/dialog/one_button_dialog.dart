import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/modal_button.dart';

class OneButtonDialog extends StatelessWidget {
  final String content;
  final void Function()? onFirstButtonClick;

  const OneButtonDialog({
    super.key,
    required this.content,
    this.onFirstButtonClick,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 15),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ModalButton(
              text: "확인",
              handlePressed: () {
                if (onFirstButtonClick != null) {
                  onFirstButtonClick!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
