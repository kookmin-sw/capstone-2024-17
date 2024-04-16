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
  bool isLogined = false;

  @override
  Widget build(BuildContext context) {
    LoginViewModel loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    if (loginViewModel.user != null) {
      isLogined = true;
    } else {
      isLogined = false;
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '유저',
            style: TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 로그인 정보 표시
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
                  await logout(context);
                  setState(() {}); // 화면 갱신
                },
                child: const Text('로그아웃'),
              ),
            ),
          ],
        )));
  }

  Future<void> logout(BuildContext context) async {
    LoginViewModel loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    await storage.deleteAll();
    loginViewModel.logout();
    setState(() {}); // context.mount ?  바로 적용이 안됨
  }
}
