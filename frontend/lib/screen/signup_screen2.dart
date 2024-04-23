import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/screen/signup_screen3.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/bottom_text_button.dart';
import 'package:frontend/widgets/iconed_textfield.dart';


class WarningLabel extends StatelessWidget {
  const WarningLabel({
    super.key,
    required this.label,
    required this.visible,
  });

  final String label;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(margin: const EdgeInsets.symmetric(vertical: 10), child: Row(
          children: <Widget>[
            const Icon(Icons.warning, color: Colors.red,),
            const SizedBox(width: 5,),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.red, overflow: TextOverflow.visible),),),
            ]),
      ),
    );
  }
}

class SignupScreen2 extends StatefulWidget {
  const SignupScreen2({super.key});

  @override
  State<SignupScreen2> createState() =>
  _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RegExp regex = RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$%^&*()]).{8,20}$');
  bool visibleWarningLabel1 = false;
  bool visibleWarningLabel2 = false;
  bool visibleWarningLabel3 = false;

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
        body:  Container(
          alignment: Alignment.center,
           margin: const EdgeInsets.only(top: 20, bottom: 40, left: 40, right: 40),
            child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  Column(children: <Widget>[
                    // 안내
                    const Row(children: <Widget>[
                      Text("사용할 아이디와 비밀번호를 입력해주세요.",
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
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 30), // 마진 추가,
                      child: Column(
                      children: <Widget>[
                        // 입력창
                        IconedTextfield(
                          icon: null,
                          hintText: '아이디',
                          controller: _loginIdController,
                          isSecret: false,
                        ),
                        WarningLabel(label: '중복된 아이디가 존재합니다.', visible: visibleWarningLabel1,),
                        const SizedBox(
                          height: 20,
                        ),
                        IconedTextfield(
                          icon: null,
                          hintText: '비밀번호',
                          controller: _passwordController,
                          isSecret: true,
                        ),
                        WarningLabel(
                            label: '비밀번호는 숫자, 소문자, 특수문자를 최소 1개 이상 포함한 8자 이상 20자 이하의 문자열이어야 합니다.', 
                            visible: visibleWarningLabel2,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        IconedTextfield(
                          icon: null,
                          hintText: '비밀번호 확인',
                          controller: _confirmPasswordController,
                          isSecret: true,
                        ),
                        WarningLabel(label: '비밀번호가 일치하지 않습니다.', visible: visibleWarningLabel3,),
                        const SizedBox(
                          height: 20,
                        ),
                      ])),
                  ]),

                  // 버튼 컨테이너
                  Container(
                    child: Column(
                      children: <Widget>[
                        BottomTextButton(text: '다음', handlePressed: nextPressed,),
                      ],
                    ),
                  ),
            ])));
  }

  void nextPressed() {
    if (_loginIdController.text == '') {
      showAlertDialog(context, '아이디를 입력해주세요.');
      return;
    }
    else if (_passwordController.text == '') {
      showAlertDialog(context, '비밀번호를 입력해주세요.');
      return;
    }

    // (아이디 중복검증 요청 추가하기)
    
    // 비밀번호 규칙
    if (!regex.hasMatch(_passwordController.text)) {
      visibleWarningLabel2 = true;
    } else {
      visibleWarningLabel2 = false;
    }

    // 비밀번호 불일치
    if (_passwordController.text != _confirmPasswordController.text) {
         visibleWarningLabel3 = true;
    } else {
      visibleWarningLabel3 = false;
    }

    if (!visibleWarningLabel1 && !visibleWarningLabel2 && !visibleWarningLabel3) {
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupScreen3(loginId: _loginIdController.text, password: _passwordController.text),
            ),
          );
        }
    else {
      setState(()=>{});
    }
  }
}