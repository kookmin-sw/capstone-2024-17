import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
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
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            '회원가입',
            textAlign: TextAlign.center,
          ),
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
              Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    '회원가입',
                    /*
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,)
                      )
                    */
                  )),

              // 입력창 컨테이너
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 140, vertical: 20), // 마진 추가
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _loginIdController,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            labelText: '아이디',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            labelText: '비밀번호 입력',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: '비밀번호 확인'),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: '사용할 닉네임'),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: '이메일'),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: '전화번호'),
                          obscureText: true,
                        ),
                      ])),
              // 버튼 컨테이너
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 140, vertical: 20), // 마진 추가,
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
                        } else if (_nicknameController.text == '') {
                          AlertDialog(content: Text('사용할 닉네임을 입력해주세요.'));
                        } else if (_emailController.text == '') {
                          AlertDialog(content: Text('이메일을 입력해주세요.'));
                        } else if (_phoneController.text == '') {
                          AlertDialog(content: Text('전화번호를 입력해주세요.'));
                        } else {
                          try {
                            signup(
                                context,
                                _loginIdController.text,
                                _passwordController.text,
                                _nicknameController.text,
                                _emailController.text,
                                _phoneController.text);
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

  void signup(BuildContext context, String loginId, String password,
      String nickname, String email, String phone) async {
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    // print(hashedPassword);
    final url = Uri.parse('http://localhost:8080/auth/signUp');
    // final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
    final data = jsonEncode({
      'loginId': loginId,
      'password': hashedPassword,
      'nickname': nickname,
      'email': email,
      'phone': phone,
    });
    try {
      http.Response res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // 요청 성공
        AlertDialog(content: Text('회원가입 성공! 로그인 페이지로 이동합니다.'));
        if (!context.mounted) return;
        Navigator.of(context).pushNamed('/signin');
      } else {
        // 예외
        AlertDialog(
            content:
                Text('회원가입 실패: ${jsonData["message"]}(${jsonData["code"]})'));
      }
    } catch (error) {
      AlertDialog(content: Text('회원가입 실패: $error'));
    }
  }
}
