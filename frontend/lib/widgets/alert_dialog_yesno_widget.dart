import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showAlertDialogYesNo(BuildContext context, String title, String message,
    [Function()? onOKPressed]) {
  // Set up the buttons
  Widget yesButton = TextButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(); // Close screen
      if (onOKPressed != null) {
        onOKPressed();
      }
    },
    child: const Text('예'),
  );

  Widget noButton = TextButton(
    onPressed: () => Navigator.of(context).pop(), // Close dialog
    child: const Text('아니오'),
  );

  // Set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      yesButton,
      noButton,
    ],
  );

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
