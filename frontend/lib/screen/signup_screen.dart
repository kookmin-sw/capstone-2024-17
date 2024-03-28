import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  child: const Text('회원가입',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ))),
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 140), // 좌우 마진 추가
                  child: Column(children: <Widget>[
                    TextField(
                      controller: _loginIdController,
                      decoration: const InputDecoration(labelText: '아이디'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: '비밀번호 확인'),
                      obscureText: true,
                    ),
                  ])),
              Container(
                margin: const EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        if (_loginIdController.text == '') {
                          AlertDialog(content: Text('아이디를 입력해주세요.'));
                        } else if (_passwordController.text == '') {
                          AlertDialog(content: Text('비밀번호를 입력해주세요.'));
                        } else if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          // 비밀번호 불일치
                          AlertDialog(content: Text('비밀번호가 일치하지 않습니다.'));
                        } else {
                          try {
                            signup(context, _loginIdController.text,
                                _passwordController.text);
                          } catch (error) {
                            AlertDialog(content: Text('요청 실패: $error'));
                          }
                        }
                      },
                      child: Text('회원가입'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signin');
                        },
                        child: const Text('로그인')),
                  ],
                ),
              ),
            ])));
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void signup(BuildContext context, String loginId, String password) async {
    final url = Uri.parse('http://localhost:8080/api/auth/signUp');
    // final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
    final data = jsonEncode({
      'loginId': loginId,
      'password': password,
      'nickname': '',
      'email': '',
      'phone': '',
    });
    try {
      http.Response res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(res.body);
        bool success = data["success"];
        if (success) {
          AlertDialog(content: Text('회원가입 성공! 로그인 페이지로 이동합니다.'));
          if (!context.mounted) return;
          Navigator.of(context).pushNamed('/signin');
        } else {
          // 예외
          AlertDialog(
              content: Text('회원가입 실패: ${data["message"]}(${data["code"]})'));
        }
      } else {
        AlertDialog(content: Text('회원가입 실패: 처리되지 않은 상태코드 ${res.statusCode}'));
      }
    } catch (error) {
      AlertDialog(content: Text('회원가입 실패: $error'));
    }
  }
}
