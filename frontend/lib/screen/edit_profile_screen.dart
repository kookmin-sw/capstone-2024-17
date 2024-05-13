import 'package:flutter/material.dart';
import 'package:frontend/screen/position_select_screen.dart';
import 'package:frontend/screen/search_company_screen.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/big_thermometer.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:frontend/service/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  String nickname = '';
  String logoInfo =
      'https://capstone2024-17-coffeechat.s3.ap-northeast-2.amazonaws.com/coffeechat-logo.png';
  String companyName = '미인증';
  String position = '';
  int temperature = 0;
  String introduction = '';
  late ScrollController _scrollController;
  late TextEditingController _nicknameController;
  late TextEditingController _introductionController;

  @override
  void initState() {
    super.initState();
    setProfile();
    _scrollController = ScrollController();
    _nicknameController = TextEditingController(text: nickname);
    _introductionController = TextEditingController(text: introduction);
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
                            Image.network(logoInfo, width: 100, height: 100),
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
                                            companyName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              Map<String, dynamic> res =
                                                  await resetCompany();
                                              if (res['success'] == true) {
                                                showAlertDialog(context,
                                                    '초기화 성공: ${res['message']}(${res['code']})');
                                              } else {
                                                showAlertDialog(context,
                                                    '초기화 실패: ${res['message']}(${res['code']})');
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text('초기화')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SearchCompanyScreen()),
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
                                            position,
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
                                                            lastPosition:
                                                                position)),
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
                                child: BigThermometer(temperature: temperature),
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
                      handlePressed: () async {
                        // 저장하는 코드
                        Map<String, dynamic> res = await updateIntroduction(
                            _introductionController.text);
                        print(res);
                        if (res['success'] == true) {
                          // 유저페이지로 이동
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/user', (route) => false);
                        } else {
                          // 요청 실패
                          showAlertDialog(context,
                              '유저정보 변경에 실패했습니다: ${res['message']}(${res['code']})');
                        }
                      },
                    ),
                  ],
                )))
      ])),
      bottomNavigationBar: const BottomAppBar(),
    );
  }

  Future<void> setProfile() async {
    // 프로필 get하는 코드
    Map<String, dynamic> res = await getUserDetail();
    if (res['success'] == true) {
      // 요청 성공
      print(res);
      nickname = res['data']['nickname'];
      if (res['data']['company'] != null) {
        logoInfo = res['data']['company']['logoUrl'];
        companyName = res['data']['company']['name'];
      }

      position = res['data']['position'];
      temperature = res['data']['coffeeBean'].round(); // 반올림
      introduction = res['data']['introduction'] ?? '';

      setState(() {}); // 상태 갱신
    } else {
      // 요청 실패
      showAlertDialog(
          context, '유저 정보 가져오기에 실패했습니다: ${res['message']}(${res['code']})');
    }
  }
}
