import 'package:flutter/material.dart';
import 'package:frontend/screen/chat_screen.dart';
import 'package:frontend/widgets/profile_img.dart';

class ChatroomItem extends StatelessWidget {
  final int id;
  final String nickname;
  final String? recentMessage;
  final int count;
  final String logoUrl;

  const ChatroomItem({
    super.key,
    required this.id,
    required this.nickname,
    required this.recentMessage,
    required this.count,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // print('탭됨: $id');
        Future.delayed(
          Duration.zero,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatroomId: id,
                  nickname: nickname,
                  logoUrl: logoUrl,
                ),
              ),
            );
          },
        );
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: (logoUrl == '')
                    ? const ProfileImgSmall(
                        isLocal: true,
                        logoUrl: "assets/coffee_bean.png",
                      )
                    : ProfileImgSmall(
                        isLocal: false,
                        logoUrl: logoUrl,
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
                            recentMessage ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        // count 뱃지: 1 이상일 시에만 보이도록 설정
                        Visibility(
                          visible: count > 0,
                          child: Container(
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
                        )
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
