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
          Text('${viewModel.isLogined}'),
          ElevatedButton(
            onPressed: () async {
              await viewModel.login();
              setState(() {}); // 화면 갱신
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.logout();
              setState(() {}); // 화면 갱신
            },
            child: const Text('Logout'),
          ),
        ],
      )),
    );
  }
}
