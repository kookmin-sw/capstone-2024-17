import 'package:flutter/material.dart';

class ChatroomItem extends StatelessWidget {
  final int id;
  final String nickname;
  final Image? logoImage;
  final String? message;
  final int count;
  final Function(int id, String nickname, Image? logoImage) chatroomTapCallback;

  const ChatroomItem({
    super.key,
    required this.id,
    required this.nickname,
    required this.logoImage,
    required this.message,
    required this.count,
    required this.chatroomTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // chatlist screen에서 chat screen으로 이동할 때 사용할 정보를 돌려주는 콜백함수
        chatroomTapCallback(id, nickname, logoImage);
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: (logoImage == null)
                      ? const AssetImage('assets/logo.png')
                      : logoImage as ImageProvider<Object>,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      // spaceBetween: child widget을 시작과 끝에 배치하고
                      // 그 사이에 나머지 child widget을 배치
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            message ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(12),
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              (count < 100) ? count.toString() : '99+',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
