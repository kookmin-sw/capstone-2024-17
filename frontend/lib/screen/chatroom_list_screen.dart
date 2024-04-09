import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screen/chat_screen.dart';
import 'package:frontend/widgets/chatroom_item.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatroomListScreen extends StatefulWidget {
  const ChatroomListScreen({super.key});

  @override
  _ChatroomListScreenState createState() => _ChatroomListScreenState();
}

class _ChatroomListScreenState extends State<ChatroomListScreen> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> chatrooms = [];

  handleChatroomTap(int id, String nickname, Image? logoImage) {
    print('채팅방 탭됨: $id');
    // 해당 id를 가진 채팅방 url로 이동: id, nickname, logoImage 전달
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                chatroomId: id, nickname: nickname, logoImage: logoImage)));
  }

  @override
  void initState() {
    super.initState();
    // getChatroomlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          '채팅방 목록',
          style: TextStyle(fontSize: 24),
        ),
        toolbarHeight: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: <Widget>[
            ChatroomItem(
                id: 1,
                nickname: 'goodnavers',
                logoImage: null,
                recentMessage: '네 거기서 봬요!',
                count: 1,
                chatroomTapCallback: handleChatroomTap(1, 'goodnavers', null)),
          ]
          //_buildChatroomItems(),
          ),
    );
  }

  List<Widget> _buildChatroomItems() {
    // 받아온 각 chatroom의 정보를 ChatroomItem으로 만들어 반환
    return chatrooms.map((chatroom) {
      int id = chatroom['chatroomId'];
      String nickname = chatroom['userInfo']['nickname'];
      // Image logoImage = chatroom['userInfo']['logoImage'];
      String? recentMessage = chatroom['recentMessage'];
      return ChatroomItem(
        id: id,
        nickname: nickname,
        logoImage: null, // 일단 null로 설정
        recentMessage: recentMessage,
        count: 0, // 일단 0으로 설정
        chatroomTapCallback: handleChatroomTap(id, nickname, null),
      );
    }).toList();
  }

  // 유저의 채팅방 목록 get: 해당 유저는 토큰으로 판단
  Future<void> getChatroomlist() async {
    final url = Uri.parse('http://localhost:8080/chatroom/list');
    final token = storage.read(key: 'authToken').toString();
    try {
      http.Response res = await http.get(
        url,
        headers: {"Content-Type": "application/json", "authToken": token},
      );
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      if (jsonData['success']) {
        // 요청 성공
        setState(() {
          chatrooms =
              List<Map<String, dynamic>>.from(jsonData['data']['chatrooms']);
        });
      } else {
        // 예외처리
        showAlertDialog(
          context,
          '채팅방 목록 불러오기 실패: ${jsonData["message"]}(${jsonData["statusCode"]})',
        );
      }
    } catch (error) {
      showAlertDialog(context, '채팅방 목록 불러오기 실패: $error');
    }
  }
}
