import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/cafe_info.dart';
import 'package:frontend/widgets/user_item.dart';
import 'package:frontend/widgets/bottom_text_button.dart';
import 'package:frontend/model/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CafeDetails(
          cafeId: "cafe-1", cafeName: "스타벅스 국민대점"), // 임시로 cafeId, cafeName 지정
    );
  }
}

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

Future<List<UserModel>> getUserList(String cafeId) async {
  List<UserModel> userList = [];
  final url = Uri.parse("https://localhost:8080/cafe/$cafeId");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> users = jsonDecode(response.body);

    for (var user in users) {
      final userModel = UserModel.fromJson(user);
      userList.add(userModel);
    }
    return userList;
  }
  throw Error();
}

class CafeDetails extends StatefulWidget {
  final String cafeId;
  final String cafeName;

  const CafeDetails({
    super.key,
    required this.cafeId,
    required this.cafeName,
  });

  @override
  State<CafeDetails> createState() => _CafeDetailsState();
}

class _CafeDetailsState extends State<CafeDetails>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<UserModel> userList = [];

  void waitForUserList(String cafeId) async {
    userList = await getUserList(cafeId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    tabController!.addListener(() {
      // 사용자 보기 탭 클릭 시, 서버에 해당 카페에 있는 유저 목록 get 요청
      if (tabController!.index == 1) {
        waitForUserList(widget.cafeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            widget.cafeName,
            style: const TextStyle(fontSize: 24),
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
          TabBar(
            controller: tabController,
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            indicatorWeight: 4,
            tabs: const [
              Tab(text: "카페 상세정보"),
              Tab(text: "사용자 보기"),
            ],
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TabBarView(
                controller: tabController,
                children: [
                  const CafeInfo(
                    location:
                        "서울특별시 성북구 정릉로 77 1층 우편번호는 어쩌고저쩌곤데 너무 멀수도있어서 그냥 안오는게 나을듯",
                    phoneNumber: "02-1234-5678",
                    businessHours: "매일 09:00 ~ 22:00\n매일 휴게시간 14:00 ~ 15:00",
                  ),
                  ListView.builder(
                    itemCount: sampleUserList.length,
                    itemBuilder: (context, index) {
                      return userList.isEmpty
                          ? UserItem(
                              nickname: sampleUserList[index]["nickname"],
                              company: sampleUserList[index]["companyName"],
                              position: sampleUserList[index]["positionName"],
                              introduction: sampleUserList[index]
                                  ["introduction"],
                            )
                          : UserItem(
                              nickname: userList[index].nickname,
                              company: userList[index].companyName,
                              position: userList[index].positionName,
                              introduction: userList[index].introduction,
                            );
                    },
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
    );
  }
}
