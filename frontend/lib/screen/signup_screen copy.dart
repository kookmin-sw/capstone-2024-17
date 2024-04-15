import 'package:flutter/material.dart';
import 'package:frontend/screen/signup_screen.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/bottom_text_button.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ],
        ),
      ),
    );
  }
}



class SignupScreen1 extends StatefulWidget {
  const SignupScreen1({super.key});

  @override
  State<SignupScreen1> createState() =>
  _SignupScreen1State();
}

class _SignupScreen1State extends State<SignupScreen1> {
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;

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
                  // 약관 체크박스 컨테이너
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20), // 마진 추가
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            LabeledCheckbox(
                              label: '(필수) 이용약관 동의',
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              value: checkboxValue1,
                              onChanged: (bool newValue) {
                                setState(() {
                                  checkboxValue1 = newValue;
                                });
                              },
                            ),
                            const Divider(height: 0),
                            LabeledCheckbox(
                              label: '(필수) 개인정보 수집 및 이용 동의',
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              value: checkboxValue2,
                              onChanged: (bool newValue) {
                                setState(() {
                                  checkboxValue2 = newValue;
                                });
                              },
                            ),
                            const Divider(height: 0),
                            const SizedBox(
                              height: 10,
                            ),
                          
                          ])),
                  // 버튼 컨테이너
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 20), // 마진 추가,
                    child: Column(
                      children: <Widget>[
                        BottomTextButton(text: '다음', handlePressed: nextPressed,),
                          
                      ],
                    ),
                  ),
            ])));
  }

  void nextPressed() {
    // 체크하지 않으면 넘어갈 수 없음
    if (!checkboxValue1 || !checkboxValue2) {
        showAlertDialog(context, '약관 동의를 해주세요.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen2(),
      ),
    );
  }
}
