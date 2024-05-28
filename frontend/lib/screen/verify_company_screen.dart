import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/model/user_profile_model.dart';
import 'package:frontend/screen/position_select_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:provider/provider.dart';

class VerifyCompanyScreen extends StatefulWidget {
  final String companyName;
  final String logoUrl;
  final String domain;

  const VerifyCompanyScreen({
    super.key,
    required this.companyName,
    required this.logoUrl,
    required this.domain,
  });

  @override
  _VerifyCompanyScreenState createState() => _VerifyCompanyScreenState();
}

class _VerifyCompanyScreenState extends State<VerifyCompanyScreen> {
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();
  String sentEmailAddress = '';
  bool _timerVisible = false;
  int timeLimit = 180;
  int _secondsLeft = 0;
  late Timer _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {});
  });
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: '회사 인증'),
      body: SingleChildScrollView(
          child: Container(
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
                    ProfileImgSmall(isLocal: false, logoUrl: widget.logoUrl),
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
                    Text("_______@${widget.domain}",
                        style: const TextStyle(fontSize: 16)),
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
                          onPressed: () => {
                            //  서버에 인증 요청
                            sendPressed(_emailIdController.text),
                          },
                          child:
                              const Text('전송', style: TextStyle(fontSize: 16)),
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
                  height: 10,
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
                            child: const Text('인증',
                                style: TextStyle(fontSize: 16)),
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

                const SizedBox(
                  height: 30,
                ),

                // 인증 성공 시 보이는 column
                Visibility(
                  visible: isVerified,
                  child: Column(children: <Widget>[
                    const Text('인증 완료!',
                        style: TextStyle(
                          color: Color(0xffff6c3e),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil(ModalRoute.withName('/editprofile'));
                          },
                          icon: const Icon(Icons.keyboard_double_arrow_left),
                          label: const Text('돌아가기',
                              style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PositionSelectScreen(
                                          lastPosition: null,
                                        )),
                              );
                            },
                            label:
                                const Icon(Icons.keyboard_double_arrow_right),
                            icon: const Text('직무 등록',
                                style: TextStyle(fontSize: 14))),
                      ],
                    ),
                  ]),
                ),
                /* 타이머 테스트용
              ElevatedButton(
                onPressed: () {
                  startTimer();
                },
                child: const Text('타이머 시작'),
              ),
              */
              ]))),
    );
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
    if (!email.endsWith('@${widget.domain}')) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const OneButtonDialog(
          content: '이메일 도메인이 일치하지 않습니다.',
        ),
      );

      return;
    }
    try {
      Map<String, dynamic> res = await verificationRequest(email);
      if (res['success']) {
        // 요청 성공
        startTimer();
        sentEmailAddress = email; // 이메일이 발송된 이메일주소 저장

        showDialog(
          context: context,
          builder: (BuildContext context) => const OneButtonDialog(
            content: '메일이 발송되었습니다. 인증코드를 입력해주세요.',
          ),
        );
      } else {
        // 요청 실패
        print('이메일 전송 실패: ${res["message"]}(${res["statusCode"]})');

        showDialog(
          context: context,
          builder: (BuildContext context) => OneButtonDialog(
            content: '이메일 전송 실패: ${res["message"]}(${res["statusCode"]})',
          ),
        );
      }
      // 에러
    } catch (error) {
      print('에러: $error');

      showDialog(
        context: context,
        builder: (BuildContext context) => OneButtonDialog(
          content: '에러: $error',
        ),
      );
    }
    return;
  }

  // 인증코드 입력 후 인증버튼 클릭 시
  void verifyPressed(verifyCode) async {
    if (verifyCode == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) => const OneButtonDialog(
          content: '인증코드를 입력해주세요.',
        ),
      );

      return;
    }
    try {
      UserProfileModel userProfile =
          Provider.of<UserProfileModel>(context, listen: false);
      Map<String, dynamic> res =
          await verification(sentEmailAddress, verifyCode);
      // print('!!!!!!!!!!!!!!!!!res: $res');
      if (res['data']['result']) {
        // 요청 성공
        isVerified = true;
        // provider에 저장
        userProfile.setCompanyLogoUrl(
            company: widget.companyName, logoUrl: widget.logoUrl);
        showDialog(
          context: context,
          builder: (BuildContext context) => const OneButtonDialog(
            content: '회사 인증이 완료되었습니다.',
          ),
        );
      } else {
        // 요청 실패
        // 인증코드를 잘못 입력한 경우: '인증 실패: ${res["message"]}(${res["statusCode"]})'
        // = '인증실패: Success(200)'
        String str = '';
        (res["statusCode"] == "200")
            ? str = '인증코드가 일치하지 않습니다.'
            : str = '인증 실패: ${res["message"]}(${res["statusCode"]})';

        showDialog(
          context: context,
          builder: (BuildContext context) => OneButtonDialog(
            content: str,
          ),
        );
      }
      // 에러
    } catch (error) {
      print('에러: $error');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              content: '에러: $error',
            ),
          );
        },
      );
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
