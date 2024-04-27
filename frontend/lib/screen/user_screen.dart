import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/login_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    setAccessToken();
    print('token: $token');
  }
  
  @override
  Widget build(BuildContext context) {
    LoginViewModel loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
        /*
    if (loginViewModel.user != null) {
      isLogined = true;
    } else {
      isLogined = false;
    }
    */

    if (token == null) {
      isLogined = false;
    } else {
      isLogined = true;
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '내 프로필',
            style: TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          /*
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back),
          ),
          */
          actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              print('설정 버튼 클릭됨');
            },
          ),
        ],
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 로그인 정보 표시
            Text('로그인됨: $isLogined'),
            Text('token: $token'),
            Text('로그인 id: ${loginViewModel.user?.loginId}'),
            Text(
              '닉네임: ${loginViewModel.user?.nickname}',
            ),
            Text(
              '로그인 타입: ${loginViewModel.user?.loginType}',
            ),

            // storage 정보 표시
            ElevatedButton(
                onPressed: () async {
                  final storageData = await storage.readAll();
                  print('스토리지: ${storageData.toString()}');
                },
                child: const Text(
                  "스토리지 콘솔에 출력",
                  style: TextStyle(fontSize: 14),
                )),

            // isLogined 상태에 따라 로그인/로그아웃 버튼이 보이게
            // 로그인되지 않았을 경우
            Visibility(
                visible: !isLogined,
                child: Row(
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
                )),

            // 로그인되었을 경우
            Visibility(
              visible: isLogined,
              child:
                  // 로그아웃 버튼
                  ElevatedButton(
                onPressed: () async {
                  await logout(context).then((_) { 
                    initState();
                  });
                },
                child: const Text('로그아웃'),
              ),
            ),
          ],
        )),
  );
  }

  Future<void> logout(BuildContext context) async {
    LoginViewModel loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    loginViewModel.logout();
    await storage.deleteAll().then((_) {
      setAccessToken();
    });
    return;
  }

  Future<String?> setAccessToken() async {
    token = await storage.read(key: 'authToken');
    setState(() {});
    return token;
  }
}
