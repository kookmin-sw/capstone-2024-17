import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'map_place.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CoffeeChatRating(),
    );
  }
}

class CoffeeChatRating extends StatefulWidget {
  const CoffeeChatRating({Key? key}) : super(key: key);

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
              padding: EdgeInsets.only(top: 10),
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
              padding: EdgeInsets.only(top: 150),
              child: GestureDetector(
                onTap: selectedIndex >= 0
                    ? () {
                        Navigator.pop(context); // 현재 화면 닫기

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Google_Map()));
                      }
                    : null, // selectedIndex가 0 이상인 경우에만 클릭 가능하도록 설정
                child: Text(
                  selectedIndex >= 0 ? 'X 닫기' : '커피콩점을 매겨주세요.',
                  style: TextStyle(
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
