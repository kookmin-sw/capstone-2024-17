import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screen/edit_profile_screen.dart';
import 'package:frontend/screen/settings_screen.dart';
import 'package:frontend/widgets/bottom_text_button.dart';

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
  String companyName = '';
  String position = '';
  int temperature = 0;
  String introduction = '';

  @override
  void initState() {
    super.initState();
    setAccessToken().then((token) {
      print('token: $token');
      setProfile(token);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '내 프로필',
            style: TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          actions: [
            if (isLogined)
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLogined)
              Column(children: [
                Text('nickname: $nickname'),
                Text('logoInfo: $logoInfo'),
                Text('companyName: $companyName'),
                Text('position: $position'),
                Text('temperature: $temperature'),
                Text('introduction: $introduction'),
                 
                BottomTextButton(
                      text: '프로필 정보 수정',
                      handlePressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              nickname: nickname, 
                              logoInfo: logoInfo, 
                              companyName: companyName, 
                              position: position, 
                              temperature: temperature, 
                              introduction: introduction,),
                          ),
                        );
                      },
                    ),
              ],)
            
            // 로그인되지 않았을 경우
            else
              Column(children: <Widget>[
                const Text('로그인이 필요한 서비스입니다.'),
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
              ],),],),),
  );
  }

  

  Future<String?> setAccessToken() async {
    token = await storage.read(key: 'authToken');
    setState(() {
      isLogined = (token != null);
    });
    return token;
  }

  Future<void> setProfile(String? token) async {
    // 토큰으로 프로필 get하는 코드
    // 임의의 프로필
    nickname = '뿡순이';
    logoInfo = 'https://capstone2024-17-coffeechat.s3.ap-northeast-2.amazonaws.com/coffeechat-logo.png';
    companyName = '쿠팡';
    position = '웹 풀스택';
    temperature = 46;
    introduction = '긴 텍스트ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ';
    return;
  }
}
