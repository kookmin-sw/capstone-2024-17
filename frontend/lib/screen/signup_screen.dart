import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/screen/signup_screen2.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/top_appbar.dart';

class ExpansionLabeledCheckbox extends StatelessWidget {
  const ExpansionLabeledCheckbox({
    super.key,
    required this.label,
    required this.labelFontSize,
    required this.expansionLabel,
    required this.expansionLabelSize,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double labelFontSize;
  final String expansionLabel;
  final double expansionLabelSize;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(value);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Checkbox(
              value: value,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              activeColor: const Color(0xffff6c3e),
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ),
          Expanded(
            child: ExpansionTile(
              title: Text(label, style: TextStyle(fontSize: labelFontSize)),
              // subtitle: Text(subLabel),
              children: <Widget>[
                ListTile(
                    title: Text(expansionLabel,
                        style: TextStyle(fontSize: expansionLabelSize))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.labelSize,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double labelSize;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: <Widget>[
          Checkbox(
            value: value,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            activeColor: const Color(0xffff6c3e),
            onChanged: (bool? newValue) {
              onChanged(newValue!);
            },
          ),
          Expanded(
            child: ListTile(
                title: Text(
              label,
              style: TextStyle(fontSize: labelSize),
            )),
          ),
        ],
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text("아래의 서비스 이용약관을 읽고 동의해주세요.",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ]),

                  // 공백
                  const SizedBox(
                    height: 30,
                  ),

                  // 약관 체크박스 컨테이너
                  Container(
                      // margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20), // 마진 추가
                      child: Column(children: <Widget>[
                    ExpansionLabeledCheckbox(
                      label: '(필수) 이용약관 동의',
                      labelFontSize: 16,
                      expansionLabel: '롸?',
                      expansionLabelSize: 14,
                      value: checkboxValue1,
                      onChanged: (bool newValue) {
                        setState(() {
                          checkboxValue1 = newValue;
                          if (checkboxValue1 && checkboxValue2) {
                            checkboxValue3 = true;
                          } else {
                            checkboxValue3 = false;
                          }
                        });
                      },
                    ),
                    const Divider(height: 0),
                    ExpansionLabeledCheckbox(
                      label: '(필수) 개인정보 수집 및 이용 동의',
                      labelFontSize: 16,
                      expansionLabel:
                          '정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?정말용?',
                      expansionLabelSize: 14,
                      value: checkboxValue2,
                      onChanged: (bool newValue) {
                        setState(() {
                          checkboxValue2 = newValue;
                          if (checkboxValue1 && checkboxValue2) {
                            checkboxValue3 = true;
                          } else {
                            checkboxValue3 = false;
                          }
                        });
                      },
                    ),
                    const Divider(height: 0),
                    LabeledCheckbox(
                      label: '약관 전체 동의',
                      labelSize: 20,
                      value: checkboxValue3,
                      onChanged: (bool newValue) {
                        setState(() {
                          checkboxValue3 = newValue;
                          checkboxValue1 = checkboxValue3;
                          checkboxValue2 = checkboxValue3;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ])),
                ],
              ),

              // 다음으로 넘어가는 버튼
              BottomTextButton(
                text: '다음',
                handlePressed: nextPressed,
              ),
            ],
          ),
        ));
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
        builder: (context) => const SignupScreen2(),
      ),
    );
  }
}
