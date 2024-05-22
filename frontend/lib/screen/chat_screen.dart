import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/chat_date.dart';
import 'package:frontend/widgets/chat_item.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';

class ChatScreen extends StatefulWidget {
  final int chatroomId;
  final String nickname;
  final String logoUrl;

  const ChatScreen({
    super.key,
    required this.chatroomId,
    required this.nickname,
    required this.logoUrl,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StompClient stompClient;
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> chats = [];
  final TextEditingController _sendingMsgController = TextEditingController();
  String token = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    subscribeChatroom(); // stompClient가 activate되고 난 후에 가능
    waitGetChatList(widget.chatroomId);
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void subscribeChatroom() async {
    token = (await storage.read(key: 'authToken')) ?? '';
    stompClient.subscribe(
        destination: '/sub/chatroom/${widget.chatroomId}',
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        callback: (frame) {
          // print('sub 성공!');
          // print(frame.body);
          Map<String, dynamic> jsonData = jsonDecode(frame.body!);
          setState(() {
            chats.add(jsonData);
          });
        });
    return;
  }

  @override
  Widget build(BuildContext context) {
    stompClient = Provider.of<StompClient>(context);

    // addPostFrameCallback: 렌더링된 후 즉시 실행
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    return Scaffold(
      appBar: ChatroomAppBar(
        logoUrl: widget.logoUrl,
        nickname: widget.nickname,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            // 채팅방
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: buildChatItems(),
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
                      sendMessage();
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

  void sendMessage() async {
    // 유저 아이디 가져오긱: 토큰이 만료되면 더이상 채팅을 못하게 됨
    int senderId;
    Map<String, dynamic> res = await getUserDetail();
    print(res);
    if (res['success']) {
      // 요청 성공
      // 아이디 저장
      senderId = res['data']['userId'];
    } else {
      // 실패: 예외처리
      print('로그인된 유저 정보를 가져올 수 없습니다: ${res["message"]}(${res["statusCode"]})');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first:
                  '로그인된 유저 정보를 가져올 수 없습니다: ${res["message"]}(${res["statusCode"]})',
            ),
          );
        },
      );
      return;
    }

    // 메시지 전송
    final message = _sendingMsgController.text;
    if (message != '') {
      token = (await storage.read(key: 'authToken')) ?? '';
      final data = jsonEncode({"senderId": senderId, "content": message});
      stompClient.send(
        destination: '/pub/chatroom/${widget.chatroomId.toString()}',
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: data,
      );
      // print('pub 성공!');
      _sendingMsgController.clear();
      setState(() {});
    }
  }

  List<Widget> buildChatItems() {
    List<Widget> items = []; // ChatItem과 ChatDate를 포함
    String? lastDate;

    //  List<Map<String, dynamic>>chats 에 들어있는 요소들을 ChatItem으로 만들어서 items에 add: 날짜가 바뀌면 ChatDate add
    for (var chat in chats) {
      String sender = chat['userInfo']['nickname'];
      String message = chat['content'];
      String date = chat['datetime'].substring(0, 13);
      String time = chat['datetime'].substring(14, 19);

      if (date != lastDate) {
        // If the date changes, add ChatDate widget
        items.add(ChatDate(date: date));
        lastDate = date;
      }

      items.add(
        ChatItem(
          isMe: !(sender == widget.nickname),
          message: message,
          date: date,
          time: time,
        ),
      );
    }

    return items;
  }

  Future<void> waitGetChatList(int chatroomId) async {
    Map<String, dynamic> res = await getChatList(chatroomId);
    if (res['success']) {
      // 요청 성공
      setState(() {
        chats =
            List<Map<String, dynamic>>.from(res['data']['messageResponses']);
      });
    } else {
      // 실패: 예외처리
      print('채팅 불러오기 실패: ${res["message"]}(${res["statusCode"]})');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first: '채팅 불러오기 실패: ${res["message"]}(${res["statusCode"]})',
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _sendingMsgController.clear();
    super.dispose();
  }
}
