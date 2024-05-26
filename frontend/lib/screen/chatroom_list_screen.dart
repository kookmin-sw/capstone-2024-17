import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/chatting/chatroom_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';

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

      // 정렬되기 전 채팅방 리스트
      List<Map<String, dynamic>> fetchedChatrooms =
          List<Map<String, dynamic>>.from(res['data']['chatrooms']);

      await Future.forEach(fetchedChatrooms, (chatroom) async {
        int chatroomId = chatroom['chatroomId'];
        String recentMessageTime = await getRecentMessageTime(chatroomId);
        // 최근 메시지가 보내진 시간을 채팅방 데이터에 추가
        chatroom['recentMessageTime'] = recentMessageTime;
      });

      // recentMessageTime이 최신인 순서대로 정렬해서 전달
      fetchedChatrooms.sort(
          (a, b) => b['recentMessageTime'].compareTo(a['recentMessageTime']));
      setState(() {
        chatrooms = fetchedChatrooms;
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

  Future<String> getRecentMessageTime(int chatroomId) async {
    // chatroomId를 이용해 해당 채팅방의 마지막 메시지 시간을 가져옴
    Map<String, dynamic> res = await getChatList(chatroomId);
    List<dynamic> messageResponses = res['data']['messageResponses'];
    if (messageResponses.isNotEmpty) {
      Map<String, dynamic> recentMessage = messageResponses.last;
      // print('!!!!!!마지막 메시지 $recentMessage');
      return recentMessage['datetime'];
    } else {
      // 메시지가 없는 경우 현재 시간 반환: 채팅방 목록의 가장 위에 표시되도록 함
      return getCurrentTimeFormatted();
    }
  }

// '1970년 01월 01일/00:00'의 형태로 현재 시간을 반환하는 함수
  String getCurrentTimeFormatted() {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}년 ${_addLeadingZero(now.month)}월 ${_addLeadingZero(now.day)}일';
    String formattedTime =
        '${_addLeadingZero(now.hour)}:${_addLeadingZero(now.minute)}';
    return '$formattedDate/$formattedTime';
  }

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
