import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_text_button.dart';
import 'package:frontend/widgets/color_text_container.dart';
import 'package:frontend/widgets/profile_img.dart';

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
        body: Column(
          children: [
            const TabBar(tabs: [
              Tab(text: '보낸 요청'),
              Tab(text: '받은 요청'),
            ]),
            Expanded(
              child: TabBarView(children: [
                const SentReqList(),
                ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return const ListTile(
                      title: Text('받은 요청'),
                    );
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class SentReqList extends StatelessWidget {
  const SentReqList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ReceiverProfile(
          nickname: "goodnavers",
          company: "네이버",
          position: "데이터 엔지니어링",
          introduction:
              "안녕하세요, goodnavers 입니다. 편하게 커피챗 걸어주세요. 어쩌고 저쩌고 블라블라블라블라블라블라블라블라블라",
        ),
        const ColorTextContainer(text: "# 당신의 업무가 궁금해요."),
        const Text(
          "자동 취소까지 남은 시간\n09:59",
          textAlign: TextAlign.center,
        ),
        BottomTextButton(text: "요청 취소하기", handlePressed: () {}),
      ],
    );
  }
}

class ReceiverProfile extends StatelessWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;

  const ReceiverProfile({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: 370,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 35,
              ),
              const ProfileImg(logo: "assets/coffee_bean.png"),
              const SizedBox(
                width: 35,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    company,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    position,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 280,
            height: 150,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Text(
                introduction,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
