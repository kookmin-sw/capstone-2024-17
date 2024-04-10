import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/chat_date.dart';
import 'package:frontend/widgets/chat_item.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final int chatroomId;
  final String nickname;
  final Image logoImage;

  const ChatScreen({
    super.key,
    required this.chatroomId,
    required this.nickname,
    required this.logoImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// 할일
// get한 채팅 표시
// 해당 id 채팅방에 연결
// pub할때마다 setstate할 것?

class _ChatScreenState extends State<ChatScreen> {
  final storage = const FlutterSecureStorage();
  List<dynamic> chats = [];
  final TextEditingController _sendingMsgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getChatList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: widget.logoImage.image,
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.nickname,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.mode_standby,
                        color: Colors.lightGreen,
                        size: 15,
                      ),
                      Text(' 온라인', style: TextStyle(fontSize: 14)),
                    ]),
              ]),
        ]),
        toolbarHeight: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back),
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            // 채팅방
            Expanded(
              child: ListView(
                children: const <Widget>[
                  // 날짜표시
                  ChatDate(date: '2024년 04월 08일'),
                  // 채팅
                  ChatItem(
                      sender: 'me',
                      message: '마라탕',
                      date: '2024년 04월 08일',
                      time: '11:48'),
                  ChatItem(
                      sender: 'other',
                      message: '네 거기서 봬요!',
                      date: '2024년 04월 08일',
                      time: '11:48'),
                ],
                //_buildChatroomItems(),
              ),
            ),

            // 입력창
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // 그림자 색상
                    spreadRadius: 1, // 그림자의 퍼짐 정도
                    blurRadius: 5, // 그림자의 흐림 정도
                    offset: const Offset(0, 3), // 그림자의 위치 조정
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _sendingMsgController,
                      decoration: const InputDecoration(
                        hintText: '보낼 메시지를 입력하세요',
                        border: InputBorder.none, // 입력 테두리 없애기
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xffff6c3e)),
                    onPressed: () {
                      // 메시지 전송 로직 작성하기
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChatItems() {
    // 받아온 각 chat들의 정보를 ChatItem으로 만들어 반환
    return chats.map((chat) {
      String sender = chat['senderId'];
      String message = chat['content'];
      String date = chat['datetime'].substring(0, 13);
      String time = chat['datetime'].substring(14, 19);
      return ChatItem(
        sender: sender,
        message: message,
        date: date,
        time: time,
      );
    }).toList();
  }

  // 채팅 list를 가져오는 메소드
  Future<void> getChatList() async {
    final url =
        Uri.parse('http://localhost:8080/chatroom/${widget.chatroomId}');
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
          chats = List<Map<String, dynamic>>.from(
              jsonData['data']['messageResponses']);
        });
      } else {
        // 예외처리
        showAlertDialog(
          context,
          '채팅 불러오기 실패: ${jsonData["message"]}(${jsonData["statusCode"]})',
        );
      }
    } catch (error) {
      showAlertDialog(context, '채팅 불러오기 실패: $error');
    }
  }
}
