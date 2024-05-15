import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'map_place.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Chat Rating',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CoffeeChatRating(), // 실행할 위젯 설정
    );
  }
}

class CoffeeChatRating extends StatefulWidget {
  const CoffeeChatRating({super.key});

  @override
  _CoffeeChatRatingState createState() => _CoffeeChatRatingState();
}

class _CoffeeChatRatingState extends State<CoffeeChatRating> {
  int selectedIndex = -1;
  final List<String> comments = [
    '별로였어요.',
    '조금 아쉬워요.',
    '보통이에요.',
    '만족스러워요.',
    '완벽해요!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 131, 88, 1.0), // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 200.0, bottom: 0),
              child: Text(
                '00님과의 커피챗\n만족하셨나요?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0), // 이미지와 텍스트 간격 조절
              child: SizedBox(
                width: 300, // Stack 너비
                height: 80, // Stack 높이
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(5, (index) {
                    return Positioned(
                      left: index * 60.0, // 이미지 간격 조절
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          print('평점 = ${index + 1}점');
                          //평점 나타냄
                        },
                        child: Image.asset(
                          index <= selectedIndex
                              ? 'assets/bean(1).png' //커피콩 채워짐
                              : 'assets/bean(0).png', //커피콩 비워짐
                          width: 70,
                          height: 70,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                selectedIndex >= 0 ? comments[selectedIndex] : '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: GestureDetector(
                onTap: selectedIndex >= 0
                    ? () async {
                        int senderId = 0; //초기화
                        int receiverId = 2; //추후 수정 필요
                        int rating = (selectedIndex + 1); //점수

                        try {
                          //로그인 한 유저의 senderId 가져오기
                          Map<String, dynamic> res = await getUserDetail();

                          if (res['success']) {
                            senderId = res['data']['userId'];
                          } else {
                            print(
                                '로그인된 유저 정보를 가져올 수 없습니다: ${res["message"]}(${res["statusCode"]})');
                          }

                          Map<String, dynamic> response =
                              await coffeeBeanReview(
                                  senderId, receiverId, rating);
                          //이동할 곳 찾기
                        } catch (e) {
                          throw Error();
                        }

                        // Navigator.pop(context); // 현재 화면 닫기

                        // 일단 주석 처리
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const Google_Map()));
                      }
                    : null, // selectedIndex가 0 이상인 경우에만 클릭 가능하도록 설정
                child: Text(
                  selectedIndex >= 0 ? '제출하기 ->' : '커피콩점을 매겨주세요.',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
