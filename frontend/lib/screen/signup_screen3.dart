import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/iconed_textfield.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/top_appbar.dart';

class SignupScreen3 extends StatefulWidget {
  final String? loginId;
  final String? password;
  const SignupScreen3({
    super.key,
    required this.loginId,
    required this.password,
  });

  @override
  State<SignupScreen3> createState() => _SignupScreen3State();
}

class _SignupScreen3State extends State<SignupScreen3> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const TopAppBar(
          title: "회원가입",
        ),
        body: Container(
          alignment: Alignment.center,
          margin:
              const EdgeInsets.only(top: 20, bottom: 40, left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  // 안내
                  const Row(children: <Widget>[
                    Text("다음 정보를 입력해주세요.",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ]),

                  //  공백
                  const SizedBox(
                    height: 30,
                  ),

                  // 입력창 컨테이너
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(children: <Widget>[
                      IconedTextfield(
                        icon: null,
                        hintText: '닉네임',
                        controller: _nicknameController,
                        isSecret: false,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      IconedTextfield(
                        icon: null,
                        hintText: '이메일',
                        controller: _emailController,
                        isSecret: false,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      IconedTextfield(
                        icon: null,
                        hintText: '전화번호',
                        controller: _phoneController,
                        isSecret: false,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]),
                  ),
                ],
              ),

              // 회원가입 버튼
              BottomTextButton(text: '회원가입 완료', handlePressed: signUpPressed),
            ],
          ),
        ));
  }

  void signUpPressed() {
    // 회원가입 진행
    if (_nicknameController.text == '') {
      showAlertDialog(context, '사용할 닉네임을 입력해주세요.');
      return;
    } else if (_emailController.text == '') {
      showAlertDialog(context, '이메일을 입력해주세요.');
      return;
    } else if (_phoneController.text == '') {
      showAlertDialog(context, '전화번호를 입력해주세요.');
      return;
    }
    try {
      waitSignup(
          context,
          widget.loginId,
          widget.password,
          _nicknameController.text,
          _emailController.text,
          _phoneController.text);
    } catch (error) {
      showAlertDialog(context, '요청 실패: $error');
    }
  }
}

void waitSignup(BuildContext context, String? loginId, String? password,
    String nickname, String email, String phone) async {
  Map<String, dynamic> res =
      await signup(loginId, password, nickname, email, phone);
  if (res['success'] == true) {
    // 요청 성공
    print(res);
    showAlertDialog(context, res['message']);
    Navigator.of(context).pushNamed('/signin');
  } else {
    // 회원가입 실패
    showAlertDialog(
        context, '회원가입 실패: ${res['message']}(${res['statusCode']})');
  }
}
