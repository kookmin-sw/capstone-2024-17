import 'package:flutter/material.dart';
import 'package:frontend/widgets/cafe_info.dart';
import 'package:frontend/widgets/user_item.dart';
import 'package:frontend/widgets/bottom_text_button.dart';

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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: AppBar(
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
          ),
          body: Column(
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
                  Tab(text: "카페 상세정보"),
                  Tab(text: "사용자 보기"),
                ],
                padding: EdgeInsets.only(top: 10, bottom: 20),
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: TabBarView(
                    children: [
                      CafeInfo(
                        location:
                            "서울특별시 성북구 정릉로 77 1층 우편번호는 어쩌고저쩌곤데 너무 멀수도있어서 그냥 안오는게 나을듯",
                        phoneNumber: "02-1234-5678",
                        businessHours:
                            "매일 09:00 ~ 22:00\n매일 휴게시간 14:00 ~ 15:00",
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
                                "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BottomTextButton(
                text: "이 카페를 내 위치로 설정하기",
                handlePressed: () {},
              ),
            ],
          ),
          bottomNavigationBar: const BottomAppBar(),
        ),
      ),
    );
  }
}