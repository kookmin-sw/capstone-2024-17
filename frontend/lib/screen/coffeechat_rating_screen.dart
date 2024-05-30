import 'package:flutter/material.dart';
import 'package:frontend/model/matching_info_model.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:provider/provider.dart';

class CoffeeChatRating extends StatefulWidget {
  final String partnerNickname;
  final int partnerId;
  final int userId;
  final String matchId;

  const CoffeeChatRating({
    super.key,
    required this.partnerId,
    required this.userId,
    required this.partnerNickname,
    required this.matchId,
  });

  @override
  _CoffeeChatRatingState createState() => _CoffeeChatRatingState();
}

class _CoffeeChatRatingState extends State<CoffeeChatRating> {
  int selectedIndex = -1;
  final List<String> comments = [
    '별로였어요 :(',
    '조금 아쉬워요..',
    '보통이에요',
    '좋았어요 :)',
    '완벽해요!',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    final matchingInfo = Provider.of<MatchingInfoModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF09676), // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 150, bottom: 0),
              child: Text(
                '${widget.partnerNickname}님과의 커피챗\n얼마나 만족하셨나요?',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100), // 이미지와 텍스트 간격 조절
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
                              ? 'assets/bean_filled.png' //커피콩 채워짐
                              : 'assets/bean_empty.png', //커피콩 비워짐
                          width: 60,
                          height: 60,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                selectedIndex >= 0 ? comments[selectedIndex] : '',
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 180),
              child: GestureDetector(
                onTap: selectedIndex >= 0
                    ? () async {
                        int rating = (selectedIndex + 1); //점수

                        Map<String, dynamic> response = await coffeeBeanReview(
                            widget.matchId,
                            widget.userId,
                            widget.partnerId,
                            rating);

                        print(response);

                        await checkReviewedRequest(
                            widget.matchId, widget.userId);

                        // 커피챗 진행중인 경우에만 종료 요청
                        if (matchingInfo.isMatching) {
                          await matchFinishRequest(
                            widget.matchId,
                            widget.userId,
                          );
                        }

                        showDialog(
                          context: context,
                          builder: (BuildContext context) => OneButtonDialog(
                            content:
                                "${widget.partnerNickname}님에게 ${selectedIndex + 1}점 반영되었습니다.\n커피챗이 종료됩니다.",
                            onFirstButtonClick: () {
                              Navigator.pop(context);
                              selectedIndexProvider.selectedIndex = 0;
                            },
                          ),
                        );

                        //이동할 곳 여기 추가하면 됨!!!

                        // Navigator.pop(context); // 현재 화면 닫기

                        // 일단 주석 처리
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const Google_Map()));
                      }
                    : null, // selectedIndex가 0 이상인 경우에만 클릭 가능하도록 설정
                child: Text(
                  selectedIndex >= 0 ? '제출하기 →' : '커피콩점을 매겨주세요.',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
