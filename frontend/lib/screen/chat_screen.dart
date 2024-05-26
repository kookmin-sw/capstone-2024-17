import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/chatting/chat_date.dart';
import 'package:frontend/widgets/chatting/chat_item.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String nickname;
  final String logoUrl;
  final int? chatroomId; // Nullable chatroomId

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.nickname,
    required this.logoUrl,
    this.chatroomId,
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
  int? chatroomId; // State에서 관리하는 chatroomId

  Future<int> getChatroomId() async {
    try {
      Map<String, dynamic> response = await matchAcceptRequest(widget.matchId);
      return response["data"]["chatroomId"];
    } catch (e) {
      // 오류 처리
      print("getChatroomId error: $e");
      return -1;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  Future<void> initializeChat() async {
    chatroomId = widget.chatroomId ?? await getChatroomId();

    if (chatroomId == -1) {
      // handle error appropriately
      return;
    }

    setState(() {});

    await subscribeChatroom(chatroomId!);
    await waitGetChatList(chatroomId!);

    // 스크롤 컨트롤러 초기화
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> subscribeChatroom(int chatroomId) async {
    token = (await storage.read(key: 'authToken')) ?? '';
    stompClient.subscribe(
      destination: '/sub/chatroom/$chatroomId',
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      callback: (frame) {
        Map<String, dynamic> jsonData = jsonDecode(frame.body!);
        setState(() {
          chats.add(jsonData);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    stompClient = Provider.of<StompClient>(context);

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
    // 유저 아이디 가져오기: 토큰이 만료되면 더이상 채팅을 못하게 됨
    int senderId;
    Map<String, dynamic> res = await getUserDetail();
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
        destination: '/pub/chatroom/$chatroomId',
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: data,
      );
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
      String datetime = _applyTimeZoneOffset(chat['datetime']);
      String date = datetime.substring(0, 13);
      String time = datetime.substring(14, 19);

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
      List<Map<String, dynamic>> fetchedChats =
          List<Map<String, dynamic>>.from(res['data']['messageResponses']);

      // 채팅방에 메시지가 없는 경우 자동 메시지 전송
      if (fetchedChats.isEmpty) {
        // 메시지 전송
        int senderId;
        Map<String, dynamic> res = await getUserDetail();
        if (res['success']) {
          // 요청 성공 => 아이디 저장
          senderId = res['data']['userId'];
          token = (await storage.read(key: 'authToken')) ?? '';
          final data =
              jsonEncode({"senderId": senderId, "content": '함께 커피챗 해요!☕️'});
          stompClient.send(
            destination: '/pub/chatroom/${chatroomId.toString()}',
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: data,
          );
          setState(() {});
        } else {
          print('첫 메시지 전송 실패: ${res["message"]}(${res["statusCode"]})');
        }
      } else {
        setState(() {
          chats = fetchedChats;
        });
      }
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

  String _applyTimeZoneOffset(String dateString) {
    // String -> DateTime
    DateTime parsedDate = _parseDateString(dateString);

    // 현재 디바이스의 시간대 오프셋 가져오기
    DateTime now = DateTime.now();
    Duration offset = now.timeZoneOffset;

    // 시간대 오프셋을 적용하여 새로운 DateTime 생성
    DateTime adjustedDate = parsedDate.add(offset);

    // DateTime -> String
    String formattedDateString = _formatDateString(adjustedDate);

    return formattedDateString;
  }

  DateTime _parseDateString(String dateString) {
    // 예: '2024년 05월 22일/20:10' -> DateTime
    List<String> dateAndTime = dateString.split('/');
    List<String> dateParts = dateAndTime[0].split(' ');
    List<String> timeParts = dateAndTime[1].split(':');

    int year = int.parse(dateParts[0].replaceAll('년', ''));
    int month = int.parse(dateParts[1].replaceAll('월', ''));
    int day = int.parse(dateParts[2].replaceAll('일', ''));
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return DateTime(year, month, day, hour, minute);
  }

  // DateTime -> String('yyyy년 MM월 dd일/HH:mm' 형식)
  String _formatDateString(DateTime date) {
    // 예: DateTime -> '2024년 05월 22일/20:10'
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');

    return '$year년 $month월 $day일/$hour:$minute';
  }
}
