import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/chatroom_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/top_appbar.dart';

class ChatroomListScreen extends StatefulWidget {
  const ChatroomListScreen({super.key});

  @override
  _ChatroomListScreenState createState() => _ChatroomListScreenState();
}

class _ChatroomListScreenState extends State<ChatroomListScreen> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> chatrooms = [];

  @override
  void initState() {
    super.initState();
    waitGetChatroomlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: '채팅방 목록',
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        children: _buildChatroomItems(),
      ),
    );
  }

  List<Widget> _buildChatroomItems() {
    // 받아온 각 chatroom의 정보를 ChatroomItem으로 만들어 반환
    return chatrooms.map((chatroom) {
      // print(chatroom);
      int id = chatroom['chatroomId'];
      String nickname = chatroom['userInfo']['nickname'];
      String? recentMessage = chatroom['recentMessage'];
      // company가 null일 때도 처리해야 함
      String logoUrl = (chatroom['userInfo']['company'] != null)
          ? chatroom['userInfo']['company']['logoUrl']
          : '';
      return ChatroomItem(
        id: id,
        nickname: nickname,
        recentMessage: recentMessage,
        count: 0, // 읽지 않은 메시지의 개수: 일단 0으로 설정
        logoUrl: logoUrl,
      );
    }).toList();
  }

  Future<void> waitGetChatroomlist() async {
    Map<String, dynamic> res = await getChatroomlist();
    if (res['success']) {
      // 요청 성공
      setState(() {
        chatrooms = List<Map<String, dynamic>>.from(res['data']['chatrooms']);
      });
    } else {
      // 실패: 예외처리
      print('채팅방 목록 불러오기 실패: ${res["message"]}(${res["statusCode"]})');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first: '채팅방 목록 불러오기 실패: ${res["message"]}(${res["statusCode"]})',
            ),
          );
        },
      );
    }
  }
}
