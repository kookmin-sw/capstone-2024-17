import 'package:flutter/material.dart';
import 'package:frontend/widgets/kakao_login_widget.dart';
import 'package:frontend/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    LoginViewModel _loginViewModel = Provider.of<LoginViewModel>(context);
    print('로그인 상태: ${_loginViewModel.isLogined}'); // 로그인되었는지 상태 출력
    print('이름: ${_loginViewModel.name}');
    print('로그인 타입: ${_loginViewModel.loginType}');

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
              Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('로그인',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ))),
              Text('로그인 상태: ${_loginViewModel.isLogined}'), // 로그인되었는지 상태 출력
              Text(
                '이름: ${_loginViewModel.name}',
              ),
              Text(
                '로그인 타입: ${_loginViewModel.loginType}',
              ),
              Container(
                  margin: const EdgeInsets.all(35),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          // setState(() => {});  // 화면 갱신
                        },
                        child: KakaoLoginWidget(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _loginViewModel.logout();
                          // setState(() {}); // 화면 갱신
                        },
                        child: const Text('로그아웃'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('회원가입')),
                    ],
                  ))
            ])));
  }
}
