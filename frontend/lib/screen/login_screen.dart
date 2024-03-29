import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/kakao_login_widget.dart';
import 'package:frontend/login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    LoginViewModel _loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '로그인',
            // textAlign: TextAlign.center,
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
              // 제목
              /*
              Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('로그인',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ))),
             */
              Text('로그인 상태: ${_loginViewModel.isLogined}'), // 로그인되었는지 상태 출력
              Text(
                '이름: ${_loginViewModel.name}',
              ),
              Text(
                '로그인 타입: ${_loginViewModel.loginType}',
              ),

              // 일반 로그인 컨테이너
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 20), // 마진 추가
                  child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _loginIdController,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            labelText: '아이디',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            labelText: '비밀번호',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_loginIdController.text == '') {
                              showAlertDialog(context, '아이디를 입력해주세요.');
                            } else if (_passwordController.text == '') {
                              showAlertDialog(context, '비밀번호를 입력해주세요.');
                            } else {
                              try {
                                login(
                                  context,
                                  _loginIdController.text,
                                  _passwordController.text,
                                );
                              } catch (error) {
                                showAlertDialog(context, '요청 실패: $error');
                              }
                            }
                          },
                          child: Text('로그인'),
                        ),
                      ])),

              // 버튼 컨테이너
              Container(
                  margin: const EdgeInsets.all(35),
                  child: Column(
                    children: <Widget>[
                      // 카카오톡 로그인 버튼
                      InkWell(
                        onTap: () async {
                          // setState(() => {});  // 화면 갱신
                        },
                        child: KakaoLoginWidget(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // 로그아웃 버튼
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

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login(
    BuildContext context,
    String loginId,
    String password,
  ) async {
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    // print(hashedPassword);
    final url = Uri.parse('http://localhost:8080/auth/signIn');
    // final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
    final data = jsonEncode({
      'loginId': loginId,
      'password': hashedPassword,
    });
    try {
      http.Response res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // 요청 성공
        // jsonData["data"]["userUUID"], jsonData["data"]["authToken"] 저장하는 코드
        showAlertDialog(context, '로그인 성공!');
        setState(() => {}); // 화면 갱신
      } else {
        // 예외
        showAlertDialog(
            context, '로그인 실패: ${jsonData["message"]}(${jsonData["code"]})');
      }
    } catch (error) {
      showAlertDialog(context, '로그인 실패: $error');
    }
  }
}
