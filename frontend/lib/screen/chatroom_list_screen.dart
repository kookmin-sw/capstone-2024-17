import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    getChatroomlist();
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
        children:
            /* <Widget>[
            const ChatroomItem(
              id: 1,
              nickname: 'goodnavers',
              logoImage: null,
              recentMessage: '네 거기서 봬요!',
              count: 100,
            ),
            ChatroomItem(
              id: 2,
              nickname: '블랙빈',
              logoImage: Image.asset("assets/coffee_bean.png"),
              recentMessage: '네 거기서 봬요!',
              count: 0,
            ),
          ]
          */
            _buildChatroomItems(),
      ),
    );
  }

  List<Widget> _buildChatroomItems() {
    // 받아온 각 chatroom의 정보를 ChatroomItem으로 만들어 반환
    return chatrooms.map((chatroom) {
      int id = chatroom['chatrooId'];
      String nickname = chatroom['userInfo']['nickname'];
      // Image logoImage = chatroom['userInfo']['logoImage'];
      String? recentMessage = chatroom['recentMessage'];
      return ChatroomItem(
        id: id,
        nickname: nickname,
        logoImage: null, // 일단 null로 설정
        recentMessage: recentMessage,
        count: 0, // 일단 0으로 설정
      );
    }).toList();
  }

  // 유저의 채팅방 목록 get: 해당 유저는 토큰으로 판단
  Future<void> getChatroomlist() async {
    final url = Uri.parse('http://localhost:8080/chatroom/list');
    // final url = Uri.parse('http://${dotenv.env['MY_IP']}:8080/chatroom/list');

    final token = (await storage.read(key: 'authToken')) ?? '';

    print("토큰은: $token");
    try {
      http.Response res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      print(jsonData);
      if (jsonData['success']) {
        // 요청 성공
        setState(() {
          chatrooms =
              List<Map<String, dynamic>>.from(jsonData['data']['chatrooms']);
        });
      } else {
        // 예외처리
        print(
            '채팅방 목록 불러오기 실패: ${jsonData["message"]}(${jsonData["statusCode"]})');
        showAlertDialog(
          context,
          '채팅방 목록 불러오기 실패: ${jsonData["message"]}(${jsonData["statusCode"]})',
        );
      }
    } catch (error) {
      print('채팅방 목록 불러오기 실패: $error');
      showAlertDialog(context, '채팅방 목록 불러오기 실패: $error');
    }
  }
}
