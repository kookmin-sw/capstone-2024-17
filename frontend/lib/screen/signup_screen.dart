import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/service/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

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
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '회원가입',
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
              // 입력창 컨테이너
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 20), // 마진 추가
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: '이메일'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                              // border: OutlineInputBorder(),
                              labelText: '전화번호'),
                        ),
                      ])),
              // 버튼 컨테이너
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 100, vertical: 20), // 마진 추가,
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        if (_loginIdController.text == '') {
                          showAlertDialog(context, '아이디를 입력해주세요.');
                        } else if (_passwordController.text == '') {
                          showAlertDialog(context, '비밀번호를 입력해주세요.');
                        } else if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          // 비밀번호 불일치
                          showAlertDialog(context, '비밀번호가 일치하지 않습니다.');
                        } else if (_nicknameController.text == '') {
                          showAlertDialog(context, '사용할 닉네임을 입력해주세요.');
                        } else if (_emailController.text == '') {
                          showAlertDialog(context, '이메일을 입력해주세요.');
                        } else if (_phoneController.text == '') {
                          showAlertDialog(context, '전화번호를 입력해주세요.');
                        } else {
                          try {
                            waitSignup(
                                context,
                                _loginIdController.text,
                                _passwordController.text,
                                _nicknameController.text,
                                _emailController.text,
                                _phoneController.text);
                          } catch (error) {
                            showAlertDialog(context, '요청 실패: $error');
                          }
                        }
                      },
                      child: const Text('회원가입'),
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

  void waitSignup(BuildContext context, String loginId, String password,
      String nickname, String email, String phone) async {
        Map<String, dynamic> res = await signup(loginId, password, nickname, email, phone);
        if (res['success'] == true) {
            // 요청 성공
            showAlertDialog(context, res['message']);
            Navigator.of(context).pushNamed('/signin');
        } else {
          // 회원가입 실패
          showAlertDialog(context, '회원가입 실패: ${res['message']}(${res['statusCode']})');
        }
      }
  }
