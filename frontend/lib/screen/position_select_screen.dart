import 'package:flutter/material.dart';
import 'package:frontend/screen/edit_profile_screen.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';

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
    '프론트엔드',
    '백엔드',
    '데이터 엔지니어',
    '디자이너',
    '마케터',
    '프론트엔드',
    '백엔드',
    '데이터 엔지니어',
    '디자이너',
    '마케터',
    '프론트엔드',
    '백엔드',
    '데이터 엔지니어',
    '디자이너',
    '마케터',
    '프론트엔드',
    '백엔드',
    '데이터 엔지니어',
    '디자이너',
    '마케터',
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
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          '직무 등록',
          style: TextStyle(fontSize: 24),
        ),
        toolbarHeight: 100,
        leading: GestureDetector(
          onTap: () {
            if (selectedPosition != widget.lastPosition) {
              // 직무를 저장하지 않고 나갈까요? 추가해주기
              print('어이쿠');
            }

            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back),
        ),
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
                  Row(
                    children: <Widget>[
                      Text(
                        "(무직인 경우 관심 분야) 현재 선택됨: $selectedPosition",
                        style: const TextStyle(
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
                                          print('선택: $position');
                                          selectedPosition = position;
                                          print('교체됨: $selectedPosition');
                                          setState(() {
                                            if (isSelected) {
                                              print('와!');
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
    // 직무 저장 요청
    // 요청 성공 시 프로필 수정화면까지 pop: Navigator.of(context).popUntil((route) => EditProfileScreen());
    // editprofileScreen은 파라미터로 넘겨받지 말고 프로필 요청 한번 더 하는 걸로 수정할 것
    print('저장버튼 클릭됨');
  }
}
