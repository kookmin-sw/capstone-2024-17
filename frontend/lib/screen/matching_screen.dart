import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/screen/coffeechat_rating_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/dialog/yn_dialog.dart';
import 'package:frontend/widgets/profile_img.dart';

class Matching extends StatefulWidget {
  final String matchId;
  final int myId;
  final String myNickname;
  final String myCompany;
  final String partnerCompany;
  final String partnerNickname;
  final int partnerId;

  const Matching({
    super.key,
    required this.myId,
    required this.myNickname,
    required this.myCompany,
    required this.partnerNickname,
    required this.matchId,
    required this.partnerCompany,
    required this.partnerId,
  });

  @override
  _MatchingWidgetState createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<Matching> {
  //무직이나 취준일 때 default 이미지 필요할 듯
  var imgpath1 = 'bean(1).png';
  var imgpath2 = 'cafe.jpeg';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF09676), // 배경색 설정
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.1),
                child: const Text(
                  '커피챗 진행중 ...', // 텍스트
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/coffee_mug.png',
                      width: 400,
                      height: 400,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.1, right: 0), // 패딩 설정
                      child: Container(
                        width: 200, // 원의 너비
                        height: 200, // 원의 높이
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // 원 모양 설정
                          color: Color(0xFFFFDED2),
                        ),
                      ),
                    ),
                    Positioned(
                      width: screenWidth * 0.2,
                      top: screenHeight * 0.2,
                      left: screenWidth * 0.15,
                      child: Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.07,
                            child: Text(
                              widget.myNickname,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Text(
                            ' X ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.07,
                            child: Text(
                              widget.partnerNickname,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.27,
                      left: screenWidth * 0.13,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: (widget.myCompany == '무소속')
                            ? const ProfileImgMedium(
                                isLocal: true,
                                logoUrl: "assets/coffee_bean.png",
                              )
                            : ProfileImgMedium(
                                isLocal: true,
                                logoUrl: "assets/${widget.myCompany}-logo.png"),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.27,
                      right: screenWidth * 0.13,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: (widget.partnerCompany == '무소속')
                            ? const ProfileImgMedium(
                                isLocal: true,
                                logoUrl: "assets/coffee_bean.png",
                              )
                            : ProfileImgMedium(
                                isLocal: true,
                                logoUrl:
                                    "assets/${widget.partnerCompany}-logo.png"),
                      ),
                    )
                  ],
                ),
              ),
              // const SizedBox(height: 10),
              SizedBox(
                width: 350, // 버튼의 너비 설정
                height: 70, // 버튼의 높이 설정
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return YesOrNoDialog(
                          content: "커피챗을 종료하시겠습니까?",
                          firstButton: "종료",
                          secondButton: "닫기",
                          handleFirstClick: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoffeeChatRating(
                                  userId: widget.myId,
                                  partnerId: widget.partnerId,
                                  partnerNickname: widget.partnerNickname,
                                  matchId: widget.matchId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20), // 버튼의 내부 패딩 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ), // 버튼의 모양 설정
                    backgroundColor: const Color(0xFF371D10), // 버튼의 배경색 설정
                  ),
                  child: const Text(
                    '커피챗 종료',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ), // 버튼 텍스트의 스타일 설정
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
