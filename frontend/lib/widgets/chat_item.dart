import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String sender;
  final String message;
  final String date;
  final String time;

  const ChatItem({
    super.key,
    required this.sender,
    required this.message,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = sender == 'me';

    // 말풍선 색상 및 정렬을 판단하여 설정
    final bubbleColor =
        isMe ? const Color(0xffff6c3e) : const Color(0xe7e7ebff);
    final textColor = isMe ? Colors.white : const Color(0xff371d10);
    final borderRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          );

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      // verticalDirection: isMe ? VerticalDirection.up : VerticalDirection.down,
      children: <Widget>[
        isMe
            ? Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  time,
                  style:
                      const TextStyle(fontSize: 12.0, color: Color(0xff371d10)),
                ),
              )
            : Container(
                constraints: const BoxConstraints(maxWidth: 300),
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: borderRadius,
                ),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 16.0, color: textColor),
                ),
              ),
        !isMe
            ? Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  time,
                  style:
                      const TextStyle(fontSize: 12.0, color: Color(0xff371d10)),
                ),
              )
            : Container(
                constraints: const BoxConstraints(maxWidth: 300),
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: borderRadius,
                ),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 16.0, color: textColor),
                ),
              ),
      ],
    );
  }
}
