import 'package:flutter/material.dart';
import 'package:frontend/widgets/chatroom_item.dart';

class ChatlistScreen extends StatefulWidget {
  @override
  _ChatlistScreenState createState() => _ChatlistScreenState();
}

class _ChatlistScreenState extends State<ChatlistScreen> {
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
            children: const <Widget>[
              // 채팅방
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname:
                      'goodnaversgoodnaversgoodnaversgoodnaversgoodnaversgoodnaversgoodnaversgoodnaversgoodnavers',
                  logoImage: null,
                  message:
                      '네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!네 거기서 봬요!',
                  count: 99),
              ChatroomItem(
                  nickname: '홍지민',
                  logoImage: null,
                  message: 'zzzzzzzzzzzzzzzzzzzzzz',
                  count: 999),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
              ChatroomItem(
                  nickname: 'goodnavers',
                  logoImage: null,
                  message: '네 거기서 봬요!',
                  count: 1),
            ]));
  }
}
