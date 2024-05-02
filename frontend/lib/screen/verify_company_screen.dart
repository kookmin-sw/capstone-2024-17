import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/rounded_img.dart';

class VerifyCompanyScreen extends StatefulWidget {
  final String companyName;
  final Image logoImage;

  const VerifyCompanyScreen({
    super.key,
    required this.companyName,
    required this.logoImage,
  });

  @override
  _VerifyCompanyScreenState createState() => _VerifyCompanyScreenState();
}

class _VerifyCompanyScreenState extends State<VerifyCompanyScreen> {
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();
  String domain = '';
  String sentEmailAddress = '';
  bool _timerVisible = false;
  int timeLimit = 180;
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
              const Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      "인증코드를 전송할 회사 이메일을 입력하세요.",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              // 회사정보 컨테이너
              Container(
                alignment: Alignment.center,
                margin:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                child: Column(children: <Widget>[
                  // 회사 로고
                  RoundedImg(image: widget.logoImage, size: 100),
                  const SizedBox(
                    height: 20,
                  ),

                  // 회사 이름
                  Text(widget.companyName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 5,
                  ),

                  // 회사 도메인
                  Text("_______$domain", style: const TextStyle(fontSize: 16)),
                  const SizedBox(
                    height: 20,
                  ),
                ]),
              ),

              // 회사 이메일 입력 및 인증코드 전송 필드
              TextFormField(
                controller: _emailIdController,
                decoration: InputDecoration(
                  hintText: '이메일 입력',
                  suffixIcon: LayoutBuilder(builder: (context, constraints) {
                    // double iconWidth = constraints.maxWidth / 4;
                    return SizedBox(
                      // width: iconWidth,
                      child: TextButton(
                        onPressed: () => sendPressed(_emailIdController.text),
                        child: const Text('전송', style: TextStyle(fontSize: 16)),
                      ),
                    );
                  }),
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
                  suffixIcon: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
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
                          child:
                              const Text('인증', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
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

              /* 타이머 테스트용
              ElevatedButton(
                onPressed: () {
                  startTimer();
                },
                child: const Text('타이머 시작'),
              ),
              */
            ])));
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

  // 전송 버튼 클릭 시
  void sendPressed(email) async {
    if (!email.endsWith(domain)) {
      showAlertDialog(context, "이메일 도메인이 일치하지 않습니다.");
      return;
    }
    try {
      Map<String, dynamic> res = await verificationRequest(email);
      if (res['success']) {
        // 요청 성공
        startTimer();
        sentEmailAddress = email; // 이메일이 발송된 이메일주소 저장
        showAlertDialog(context, "메일이 발송되었습니다. 인증코드를 입력해주세요.");
      } else {
        // 요청 실패
        print('이메일 전송 실패: ${res["message"]}(${res["statusCode"]})');
        showAlertDialog(
          context,
          '이메일 전송 실패: ${res["message"]}(${res["statusCode"]})',
        );
      }
      // 에러
    } catch (error) {
      print('에러: $error');
      showAlertDialog(context, '에러: $error');
    }
    return;
  }

  // 도메인 설정
  void setDomain() {
    // 넘겨받은 도메인 set하기!
    domain = '@kookmin.ac.kr'; // 임시 도메인
  }

  // 인증코드 입력 후 인증버튼 클릭 시
  void verifyPressed(verifyCode) async {
    if (verifyCode == '') {
      showAlertDialog(context, "인증코드를 입력해주세요.");
      return;
    }
    try {
      Map<String, dynamic> res =
          await verification(sentEmailAddress, verifyCode);
      if (res['success']) {
        // 요청 성공
        showAlertDialog(context, "회사 인증이 완료되었습니다.");
      } else {
        // 요청 실패
        print('인증 실패: ${res["message"]}(${res["statusCode"]})');
        showAlertDialog(
          context,
          '인증 실패: ${res["message"]}(${res["statusCode"]})',
        );
      }
      // 에러
    } catch (error) {
      print('에러: $error');
      showAlertDialog(context, '에러: $error');
    }
    return;
  }

  @override
  void dispose() {
    _emailIdController.dispose();
    _verifyCodeController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
