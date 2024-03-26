import 'package:flutter/material.dart';
import 'package:frontend/widgets/user_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "스타벅스 국민대점",
            style: TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          backgroundColor: Colors.white,
          elevation: 1.0,
          shadowColor: Colors.black,
          leading: const Icon(Icons.arrow_back_ios),
          leadingWidth: 70,
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            children: [
              UserItem(
                nickname: "뽕순이",
                company: "채연컴퍼니",
                position: "집사",
                introduction: "안녕하세요 뽕순이입니다 뽕",
              ),
              UserItem(
                  nickname: "담",
                  company: "네카라쿠배당토",
                  position: "웹 프론트엔드",
                  introduction: "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ"),
            ],
          ),
        ),
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}
