import 'package:flutter/material.dart';
import 'package:frontend/screen/edit_profile_screen.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/top_appbar.dart';

class PositionSelectScreen extends StatefulWidget {
  final String? lastPosition;

  const PositionSelectScreen({super.key, required this.lastPosition});

  @override
  PositionSelectScreenState createState() => PositionSelectScreenState();
}

class PositionSelectScreenState extends State<PositionSelectScreen> {
  late ScrollController _scrollController;
  late String selectedPosition;

  List<String> positions = [
    '서버/백엔드',
    '프론트엔드',
    '웹 풀스택',
    '안드로이드',
    'iOS',
    '머신러닝',
    '인공지능(AI)',
    '데이터 엔지니어링',
    'DBA',
    '모바일 게임',
    '게임 클라이언트',
    '게임 서버',
    '시스템/네트워크',
    '시스템 소프트웨어',
    '데브옵스',
    '인터넷 보안',
    '임베디드 소프트웨어',
    '로보틱스 미들웨어',
    'QA',
    '사물인터넷(IoT)',
    '응용 프로그램',
    '블록체인',
    '개발PM',
    '웹 퍼블리싱',
    '크로스 플랫폼',
    'VR/AR/3D',
    'ERP',
    '그래픽스',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    selectedPosition = widget.lastPosition ?? '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: "직무 등록",
      ),
      body: Container(
          alignment: Alignment.center,
          margin:
              const EdgeInsets.only(top: 20, bottom: 40, left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Text(
                        "직무를 선택하세요.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: <Widget>[
                      Text(
                        "(무직인 경우 관심 분야)",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        height: 320,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: Wrap(
                                children: positions.map((position) {
                                  return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: ChoiceChip(
                                        label: Text(position),
                                        labelStyle: const TextStyle(),
                                        padding: const EdgeInsets.all(0),
                                        selected: selectedPosition == position,
                                        selectedColor: const Color(0xffff6c3e),
                                        backgroundColor: Colors.grey[300],
                                        side: const BorderSide(
                                            style: BorderStyle.none),
                                        onSelected: (isSelected) {
                                          selectedPosition = position;

                                          setState(() {
                                            if (isSelected) {
                                              selectedPosition = position;
                                            }
                                          });
                                        },
                                        showCheckmark: false,
                                      ));
                                }).toList(),
                              ),
                            )),
                      ),
                    ]),
                  )
                ],
              ),
              BottomTextButton(
                text: '저장하기',
                handlePressed: savePressed,
              ),
            ],
          )),
      bottomNavigationBar: const BottomAppBar(),
    );
  }

  void savePressed() {
    // 직무 저장 요청하기
    // Navigator.of(context).popUntil((route) => route is EditProfileScreen); // 안됨
    print('저장버튼 클릭됨');
  }
}
