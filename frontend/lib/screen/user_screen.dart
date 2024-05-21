import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/model/user_id_model.dart';
import 'package:frontend/screen/edit_profile_screen.dart';
import 'package:frontend/screen/settings_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/big_thermometer.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final storage = const FlutterSecureStorage();
  String? token;
  bool isLogined = false;
  String nickname = '';
  String logoInfo = '';
  String companyName = '미인증';
  String position = '선택안함';
  int temperature = 0;
  String introduction = '';
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    setAccessToken().then((token) {
      print('token: $token');
      if (token != null) {
        verifyToken(token);
      }
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserIdModel userId = Provider.of<UserIdModel>(context, listen: true);
    Map<String, dynamic> profile = userId.profile;
    print('[userscreen profile] $profile');
    return Scaffold(
      appBar: TopAppBarWithButton(
        title: "내 프로필",
        buttons: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          if (isLogined)
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
                                      Row(children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            profile["nickname"],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ]),
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
                                        temperature: profile["rating"].toInt()),
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
                              Row(children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    height: 90,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
                                        scrollDirection: Axis.vertical,
                                        child: Text(
                                          profile["introduction"],
                                          // textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                        ])),

                        // 프로필 수정 버튼
                        BottomTextButton(
                          text: '프로필 정보 수정',
                          handlePressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                  settings: const RouteSettings(
                                      name: '/editprofile')),
                            );
                          },
                        ),
                      ],
                    )))
          // 로그인되지 않았을 경우
          else
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('로그인이 필요한 서비스입니다.'),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 로그인 버튼
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signin');
                          },
                          child: const Text('로그인')),

                      // 회원가입 버튼
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('회원가입')),
                    ],
                  )
                ],
              ),
            ),
        ],
      )),
    );
  }

  Future<String?> setAccessToken() async {
    token = await storage.read(key: 'authToken');
    setState(() {
      isLogined = (token != null);
    });
    return token;
  }

  // 토큰 유효한지 확인
  Future<void> verifyToken(String? token) async {
    // 토큰으로 프로필 get
    Map<String, dynamic> res = await getUserDetail();
    if (res['success'] != true) {
      if (res['code'] == "1401") {
        showAlertDialog(context, '로그인 시간이 만료되어 재로그인이 필요합니다.');
      } else {
        // 요청 실패
        showAlertDialog(
            context, '유저 정보 가져오기에 실패했습니다: ${res['message']}(${res['code']})');
      }
    }
    return;
  }
}
