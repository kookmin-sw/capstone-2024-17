import 'package:flutter/material.dart';
import 'package:frontend/model/user_id_model.dart';
import 'package:frontend/screen/position_select_screen.dart';
import 'package:frontend/screen/search_company_screen.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/big_thermometer.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:frontend/service/api_service.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String nickname;
  final String introduction;

  const EditProfileScreen(
      {super.key, required this.nickname, required this.introduction});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  late ScrollController _scrollController;
  late TextEditingController _nicknameController;
  late TextEditingController _introductionController;
  late UserIdModel userId;

  @override
  void initState() {
    super.initState();
    setProfile();
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
    ChangeNotifierProvider(create: (_) => UserIdModel());
    Map<String, dynamic> profile = userId.profile;
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
                            Image.network(profile["logoUrl"],
                                width: 100, height: 100),
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
                                            profile["company"],
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
                                            profile["position"],
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
                                                            lastPosition: profile[
                                                                "position"])),
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
                                    temperature: profile["rating"]),
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
                          // provider에 저장
                          userId.setNicknameIntroduction();
                          // 유저페이지로 pop
                          Navigator.pop(context);
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
