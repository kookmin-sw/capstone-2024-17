import 'package:flutter/material.dart';

class ChatDate extends StatelessWidget {
  final String date;

  const ChatDate({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(children: <Widget>[
          const Expanded(child: Divider()),
          Text(date),
          const Expanded(child: Divider()),
        ]));
  }
}
