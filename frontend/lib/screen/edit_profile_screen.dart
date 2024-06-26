import 'package:flutter/material.dart';
import 'package:frontend/model/user_profile_model.dart';
import 'package:frontend/screen/position_select_screen.dart';
import 'package:frontend/screen/search_company_screen.dart';
import 'package:frontend/widgets/thermometer/big_thermometer.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';
import 'package:frontend/service/api_service.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
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
    _nicknameController = TextEditingController();
    _introductionController = TextEditingController();
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
    UserProfileModel userProfile =
        Provider.of<UserProfileModel>(context, listen: true);
    Map<String, dynamic> profile = userProfile.profile;
    _nicknameController.text = profile["nickname"];
    _introductionController.text = profile["introduction"];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const TopAppBar(
        title: "프로필 수정",
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // 유저 정보 컨테이너
                    Column(
                      children: <Widget>[
                        // 유저 프로필
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: <Widget>[
                              (profile["logoUrl"] == '')
                                  ? const ProfileImgMedium(
                                      isLocal: true,
                                      logoUrl: "assets/coffee_bean.png")
                                  : ProfileImgMedium(
                                      isLocal: false,
                                      logoUrl: profile["logoUrl"]),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color(0xffff6c3e)),
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                              userProfile.setCompanyLogoUrl(
                                                  company: '미인증', logoUrl: '');

                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    OneButtonDialog(
                                                  content:
                                                      "초기화 성공: ${res['message']}(${res['code']})",
                                                ),
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    OneButtonDialog(
                                                  content:
                                                      "초기화 실패: ${res['message']}(${res['code']})",
                                                ),
                                              );
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('초기화'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SearchCompanyScreen(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('수정'),
                                        ),
                                      ],
                                    ),
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
                                                  lastPosition:
                                                      profile["position"],
                                                ),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('수정'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 유저 커피온도
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: <Widget>[
                              const Row(
                                children: <Widget>[Text('나의 커피온도')],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: BigThermometer(
                                      temperature: profile["rating"].toInt(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 유저 자기소개
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: <Widget>[
                              const Row(
                                children: <Widget>[Text('자기소개')],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: SizedBox(
                                      height: 90,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xffff6c3e)),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          hintText: '자기소개 입력',
                                        ),
                                        controller: _introductionController,
                                        maxLines: null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 저장 버튼
                    BottomTextButton(
                      text: '저장하기',
                      handlePressed: () async {
                        // 닉네임 업데이트
                        Map<String, dynamic> res1 =
                            await updateNickname(_nicknameController.text);
                        // introduction 업데이트
                        Map<String, dynamic> res2 = await updateIntroduction(
                            _introductionController.text);
                        if (res1['success'] && res2['success'] == true) {
                          // provider에 저장
                          userProfile.setNicknameIntroduction(
                            nickname: _nicknameController.text,
                            introduction: _introductionController.text,
                          );
                          // 유저페이지로 pop
                          Navigator.pop(context);
                        } else {
                          // 요청 실패

                          showDialog(
                            context: context,
                            builder: (context) => OneButtonDialog(
                              content:
                                  "유저정보 변경에 실패했습니다: ${res1['message']}(${res1['code']})",
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
