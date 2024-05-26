import 'package:flutter/material.dart';
import 'package:frontend/model/user_profile_model.dart';
import 'package:frontend/screen/edit_profile_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';
import 'package:provider/provider.dart';

class PositionSelectScreen extends StatefulWidget {
  final String? lastPosition;

  const PositionSelectScreen({super.key, required this.lastPosition});

  @override
  PositionSelectScreenState createState() => PositionSelectScreenState();
}

class PositionSelectScreenState extends State<PositionSelectScreen> {
  late ScrollController _scrollController;
  late String selectedPosition;
  List<String> positions = [];

  @override
  void initState() {
    super.initState();
    setPositionList();

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
    UserProfileModel userProfile =
        Provider.of<UserProfileModel>(context, listen: true);
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
                                children: _buildPositionItems(),
                              ),
                            )),
                      ),
                    ]),
                  )
                ],
              ),
              BottomTextButton(
                  text: '저장하기',
                  handlePressed: () {
                    // 서버에 저장 요청
                    savePressed();
                    // provider에 저장
                    userProfile.setPosition(selectedPosition);
                  }),
            ],
          )),
    );
  }

  List<Widget> _buildPositionItems() {
    return positions.map((position) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: ChoiceChip(
            label: Text(position),
            labelStyle: const TextStyle(),
            padding: const EdgeInsets.all(0),
            selected: selectedPosition == position,
            selectedColor: const Color(0xffff6c3e),
            backgroundColor: Colors.grey[300],
            side: const BorderSide(style: BorderStyle.none),
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
    }).toList();
  }

  void setPositionList() async {
    Map<String, dynamic> res = await getPositionlist();
    print(res['data']);
    if (res['success']) {
      // 요청 성공
      setState(() {
        positions = List<String>.from(res['data']);
      });
    } else {
      // 요청 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: OneButtonDialog(
              first: '직무 리스트를 불러올 수 없습니다.',
            ),
          );
        },
      );
    }
  }

  void savePressed() async {
    // 직무 저장 요청하기
    Map<String, dynamic> res = await updatePosition(selectedPosition);
    if (res['success']) {
      // 직무 저장 성공

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first: '직무가 저장되었습니다!',
              onFirstButtonClick: () {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('/editprofile'));
              },
            ),
          );
        },
      );
    } else {
      // 직무 저장 실패

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first: '직무 저장 실패: ${res['message']}(${res['code']})',
            ),
          );
        },
      );
    }
  }
}
