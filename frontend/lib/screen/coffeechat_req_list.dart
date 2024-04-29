import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/color_text_container.dart';
import 'package:frontend/widgets/user_details.dart';
import 'package:frontend/widgets/user_item.dart';

const List<Map<String, dynamic>> sampleUserList = [
  {
    "nickname": "뽕순이",
    "companyName": "채연컴퍼니",
    "positionName": "집사",
    "introduction": "안녕하세요 뽕순이입니다 뽕",
  },
  {
    "nickname": "담",
    "companyName": "네카라쿠배당토",
    "positionName": "웹 프론트엔드",
    "introduction": "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ"
  },
  {
    "nickname": "잠온다",
    "companyName": "구글",
    "positionName": "데이터 엔지니어",
    "introduction": "잠오니까 요청하지 마세요. 감사합니다."
  },
  {
    "nickname": "내가제일잘나가",
    "companyName": "꿈의직장",
    "positionName": "풀스택",
    "introduction": "안녕하세요, 저는 제일 잘나갑니다. 잘 부탁드립니다. 요청 마니주세용 >3<"
  },
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CoffeechatReqList());
  }
}

class CoffeechatReqList extends StatelessWidget {
  const CoffeechatReqList({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            title: const Text(
              "커피챗 요청 목록",
              style: TextStyle(fontSize: 24),
            ),
            toolbarHeight: 100,
            backgroundColor: Colors.white,
            leading: const Icon(Icons.arrow_back_ios),
            leadingWidth: 70,
          ),
        ),
        body: const Column(
          children: [
            TabBar(tabs: [
              Tab(text: '보낸 요청'),
              Tab(text: '받은 요청'),
            ]),
            Expanded(
              child: TabBarView(children: [
                SentReq(),
                ReceivedReq(),
              ]),
            ),
          ],
        ),
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}

class SentReq extends StatelessWidget {
  const SentReq({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
          width: 370,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: const UserDetails(
            nickname: "goodnavers",
            company: "네이버",
            position: "데이터 엔지니어링",
            introduction:
                "안녕하세요, goodnavers 입니다. 편하게 커피챗 걸어주세요. 어쩌고 저쩌고 블라블라블라블라블라블라블라블라블라",
          ),
        ),
        const ColorTextContainer(text: "# 당신의 업무가 궁금해요."),
        const Expanded(child: SizedBox()),
        const Text(
          "자동 취소까지 남은 시간\n09:59",
          textAlign: TextAlign.center,
        ),
        BottomTextButton(text: "요청 취소하기", handlePressed: () {}),
      ],
    );
  }
}

class ReceivedReq extends StatelessWidget {
  const ReceivedReq({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: sampleUserList.length,
        itemBuilder: (context, index) {
          return UserItem(
            type: "receivedReqUser",
            nickname: sampleUserList[index]["nickname"],
            company: sampleUserList[index]["companyName"],
            position: sampleUserList[index]["positionName"],
            introduction: sampleUserList[index]["introduction"],
          );
        },
      ),
    );
  }
}
