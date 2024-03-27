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
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
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
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: [
                Image.asset(
                  "assets/cafe.jpeg",
                  width: 450,
                  fit: BoxFit.fitWidth,
                ),
                const TabBar(
                    indicatorColor: Colors.black,
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    indicatorWeight: 4,
                    tabs: [
                      Tab(
                        text: "카페 상세정보",
                      ),
                      Tab(
                        text: "사용자 보기",
                      ),
                    ]),
                const Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          Text("위치: 서울특별시 성북구 정릉로 77"),
                          Text("전화번호: 02-1234-5678"),
                          Text("영업시간: 07:00 ~ 22:00"),
                        ],
                      ),
                      Column(
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
                              introduction:
                                  "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BottomAppBar(),
        ),
      ),
    );
  }
}
