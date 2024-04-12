import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/suffix_textfield.dart';

class VerifyCompanyScreen extends StatefulWidget {
  final String companyName;

  const VerifyCompanyScreen({
    super.key,
    required this.companyName,
  });

  @override
  _VerifyCompanyScreenState createState() => _VerifyCompanyScreenState();
}

class _VerifyCompanyScreenState extends State<VerifyCompanyScreen> {
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();
  String domain = '';
  bool _timerVisible = false;
  int timeLimit = 10;
  int _secondsLeft = 0;
  late Timer _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {});
  });

  @override
  void initState() {
    super.initState();
    setDomain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '회사 인증',
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
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(children: <Widget>[
              const Row(children: <Widget>[
                Text("코드를 전송할 회사 이메일을 입력하세요.",
                    style: TextStyle(
                      fontSize: 20,
                    )),
              ]),
              const SizedBox(
                height: 20,
              ),
/*
              Text("회사: ${widget.companyName}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(
                height: 20,
              ),
*/
              // 회사 이메일 입력 및 인증코드 전송 필드
              TextField(
                controller: _emailIdController,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[@]')),
                ],
                decoration: InputDecoration(
                  hintText: '이메일 입력',
                  suffixIcon: LayoutBuilder(
                    builder: (context, constraints) {
                      double iconWidth = constraints.maxWidth *
                          2 /
                          3; // suffixIcon의 너비가 TextField의 절반이 되도록 함
                      return SizedBox(
                        width: iconWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              domain,
                              style: const TextStyle(
                                fontSize: 18,
                                // fontWeight: FontWeight.bold,
                                // color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  sendPressed(_emailIdController.text),
                              child: const Text('전송',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffff6c3e)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // 인증코드 입력 및 제출 필드
              TextField(
                controller: _verifyCodeController,
                decoration: InputDecoration(
                  hintText: '인증코드 입력',
                  suffixIcon: LayoutBuilder(
                    builder: (context, constraints) {
                      double iconWidth = constraints.maxWidth / 4;
                      return SizedBox(
                        width: iconWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // 타이머가 들어갈 자리
                            if (_timerVisible)
                              Text(
                                '${_secondsLeft ~/ 60}:${_secondsLeft % 60}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            TextButton(
                              onPressed: () =>
                                  verifyPressed(_verifyCodeController.text),
                              child: const Text('인증',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffff6c3e)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              // 타이머
              const SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () {
                  startTimer();
                },
                child: const Text('타이머 시작'),
              ),
            ])));
  }

  void sendPressed(emailId) async {
    // 서버에서 인증번호 받아오기
    const verifyCode = '123456'; // 임시로 사용?
    // verifyCode를 이메일에 전송하기
    String emailAdress = emailId + domain;
    if (await _sendEmail(emailAdress, verifyCode)) {
      showAlertDialog(context, "메일이 발송되었습니다. 인증코드를 확인해주세요.");
    }
    return;
  }

  // 도메인 설정(or screen에 넘겨주기?)
  void setDomain() {
    domain = '@gmail.com';
  }

  void verifyPressed(verifyCode) async {
    // 서버에 인증번호 전송, 비교
    // 성공시
    showAlertDialog(context, "회사 인증이 완료되었습니다.");
  }

  void startTimer() {
    _timer.cancel();
    _timerVisible = true;
    _secondsLeft = timeLimit;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer.cancel();
          _timerVisible = false;
        }
      });
    });
  }

  Future<bool> _sendEmail(String emailAdress, String verifyCode) async {
    final Email email = Email(
      body: '인증코드를 확인해주세요. [$verifyCode]',
      subject: '[커리어 한 잔] 회사 인증 메일입니다.',
      recipients: [emailAdress],
      cc: [], // 참조
      bcc: [], // 숨은참조
      attachmentPaths: [], // 첨부
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
      return true;
    } catch (error) {
      String message = "이메일 전송 에러: $error";
      print(message);
      await showAlertDialog(context, message);
    }
    return false;
  }

  @override
  void dispose() {
    _emailIdController.dispose();
    _verifyCodeController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
