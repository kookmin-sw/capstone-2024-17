import 'package:flutter/material.dart';
import 'package:frontend/kakao_login.dart';
import 'package:frontend/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<LoginScreen> {
  final viewModel = LoginViewModel(KakaoLogin());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(20),
              child: const Text('로그인',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ))),
          Text('로그인 상태: ${viewModel.isLogined}'), // 로그인되었는지 상태 출력
          Image.network(
            viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? '',
            width: 50,
            height: 50,
          ),
          Text(
            '이름: ${viewModel.user?.kakaoAccount?.profile?.nickname ?? ' - '}',
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () async {
                await viewModel.login();
                setState(() {}); // 화면 갱신
              },
              child: Image.asset('assets/kakao_login_medium_narrow.png'),
            ),
          ),
          TextButton(
            onPressed: () async {
              await viewModel.logout();
              setState(() {}); // 화면 갱신
            },
            child: const Text('로그아웃'),
          ),
        ],
      )),
    );
  }
}
