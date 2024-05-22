import 'package:flutter/material.dart';

void showAlertDialogYesNo(
  BuildContext context, {
  required String message,
  Function()? onOKPressed,
  String yesButtonText = "예",
  String noButtonText = "아니오",
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 20.0),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff212121),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      if (onOKPressed != null) {
                        onOKPressed();
                      }
                    },
                    child: Text(
                      yesButtonText,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff212121),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(), // Close dialog
                    child: Text(
                      noButtonText,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
