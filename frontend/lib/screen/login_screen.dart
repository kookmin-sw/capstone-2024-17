import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/user_model.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/iconed_textfield.dart';
import 'package:frontend/widgets/bottom_text_button.dart';
import 'package:frontend/widgets/bottom_text_secondary_button.dart';
import 'package:frontend/widgets/kakao_login_widget.dart';
import 'package:frontend/login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    LoginViewModel _loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    if (_loginViewModel.user != null) {
      // 현재 페이지를 대신해 유저 페이지로 navigate
      // push나 pop의 재진입 현상 방지
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed('/user');
      });
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '로그인',
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
        body: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: Column(children: <Widget>[
              // 로고
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                ),
              ),

              // 일반 로그인 컨테이너
              Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Column(children: <Widget>[
                    // 입력창
                    Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Column(
                          children: <Widget>[
                            IconedTextfield(
                              icon: const Icon(Icons.person_outline),
                              hintText: '아이디',
                              controller: _loginIdController,
                              isSecret: false,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            IconedTextfield(
                              icon: const Icon(Icons.lock_outline),
                              hintText: '비밀번호',
                              controller: _passwordController,
                              isSecret: true,
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    BottomTextButton(
                      text: '로그인',
                      handlePressed: () async {
                        if (_loginIdController.text == '') {
                          showAlertDialog(context, '아이디를 입력해주세요.');
                        } else if (_passwordController.text == '') {
                          showAlertDialog(context, '비밀번호를 입력해주세요.');
                        } else {
                          try {
                            await login(
                              context,
                              _loginIdController.text,
                              _passwordController.text,
                            );
                          } catch (error) {
                            showAlertDialog(context, '요청 실패: $error');
                          }
                          setState(() {}); // 화면 갱신
                        }
                      },
                    ),
                    BottomTextSecondaryButton(
                      text: '회원가입',
                      handlePressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                    )
                  ])),
              // 구분선
              const Row(children: <Widget>[
                Expanded(child: Divider()),
                Text("또는"),
                Expanded(child: Divider()),
              ]),

              // 소셜 로그인 컨테이너
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                child: Column(
                  children: <Widget>[
                    // 카카오톡 로그인 버튼
                    GestureDetector(
                      onTap: () {
                        // setState(() {}); // 왜 안되징
                      },
                      child: KakaoLoginWidget(),
                    ),
                  ],
                ),
              )
            ])));
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login(
    BuildContext context,
    String loginId,
    String password,
  ) async {
    LoginViewModel _loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final url = Uri.parse('http://localhost:8080/auth/signIn');
    // final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
    final data = jsonEncode({
      'loginId': loginId,
      'password': hashedPassword,
    });
    // setState(() {});
    try {
      http.Response res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // 요청 성공
        // storage에는 userUUID와 토큰 저장
        await storage.write(
            key: 'userUUID', value: jsonData["data"]["userUUID"]);
        await storage.write(
            key: 'authToken', value: jsonData["data"]["authToken"]);
        // 아이디와 닉네임, 로그인타입으로 UserModel 만들어서 provider에 로그인
        UserModel user = UserModel(loginId, 'none', 'none');
        _loginViewModel.login(user);
        showAlertDialog(context, '로그인 성공!');
        // 현재 페이지를 대신해 유저 페이지로 navigate
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed('/user');
        });
      } else {
        // 로그인 예외처리
        showAlertDialog(
            context, '로그인 실패: ${jsonData["message"]}(${jsonData["code"]})');
      }
      // 에러
    } catch (error) {
      showAlertDialog(context, '로그인 실패: $error');
    }
  }
}
