import 'package:flutter/material.dart';
import 'package:frontend/screen/position_select_screen.dart';
import 'package:frontend/widgets/big_thermometer.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/top_appbar.dart';

class EditProfileScreen extends StatefulWidget {
  final String nickname;
  final String logoInfo;
  final String companyName;
  final String position;
  final int temperature;
  final String introduction;

  const EditProfileScreen({
    super.key,
    required this.nickname,
    required this.logoInfo,
    required this.companyName,
    required this.position,
    required this.temperature,
    required this.introduction,
  });

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  late ScrollController _scrollController;
  late TextEditingController _nicknameController;
  late TextEditingController _introductionController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _nicknameController = TextEditingController(text: widget.nickname);
    _introductionController = TextEditingController(text: widget.introduction);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nicknameController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const TopAppBar(
        title: "프로필 수정",
      ),
      body: Center(
          child: Column(children: <Widget>[
        Expanded(
            child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // 유저 정보 컨테이너
                    Container(
                        child: Column(children: <Widget>[
                      // 유저 프로필
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: <Widget>[
                            Image.network(
                              widget.logoInfo,
                              scale: 4,
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Flexible(
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                  TextField(
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color(0xffff6c3e)),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      hintText: '닉네임',
                                    ),
                                    controller: _nicknameController,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            widget.companyName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text('수정')),
                                      ]),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            widget.position,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PositionSelectScreen(
                                                            lastPosition: widget
                                                                .position)),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text('수정')),
                                      ])
                                ])),
                          ],
                        ),
                      ),

                      // 유저 커피온도
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(children: <Widget>[
                            const Row(
                              children: <Widget>[Text('나의 커피온도')],
                            ),
                            Row(children: <Widget>[
                              Expanded(
                                child: BigThermometer(
                                    temperature: widget.temperature),
                              )
                            ]),
                          ])),

                      // 유저 자기소개
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(children: <Widget>[
                          const Row(
                            children: <Widget>[Text('자기소개')],
                          ),
                          const SizedBox(height: 10),
                          Row(children: <Widget>[
                            Expanded(
                              child: SizedBox(
                                height: 90,
                                child: TextField(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xffff6c3e)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    hintText: '자기소개 입력',
                                  ),
                                  controller: _introductionController,
                                  maxLines: null,
                                ),
                              ),
                            ),
                          ]),
                        ]),
                      ),
                    ])),

                    // 저장 버튼
                    BottomTextButton(
                      text: '저장하기',
                      handlePressed: () {
                        // 저장하는 코드
                        // 유저페이지로 이동
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/user', (route) => false);
                      },
                    ),
                  ],
                )))
      ])),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}
