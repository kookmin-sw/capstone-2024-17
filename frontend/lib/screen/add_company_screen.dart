import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/textfield/iconed_textfield.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _bnoController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopAppBar(
          title: "회사 추가 요청",
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    // 안내
                    const Row(children: <Widget>[
                      Flexible(
                        child: Text("재직 중인 회사의 정보를 입력하세요.",
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ),
                    ]),

                    // 입력창 컨테이너
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(children: <Widget>[
                        IconedTextfield(
                          icon: null,
                          hintText: '회사명',
                          controller: _companyNameController,
                          isSecret: false,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        IconedTextfield(
                          icon: null,
                          hintText: '사업자 등록번호',
                          controller: _bnoController,
                          isSecret: false,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        IconedTextfield(
                          icon: null,
                          hintText: '사내메일 도메인  ex) @kookmin.ac.kr',
                          controller: _domainController,
                          isSecret: false,
                        ),
                      ]),
                    ),
                  ],
                ),

                // 추가요청 버튼
                BottomTextButton(
                    text: '회사 추가 요청하기', handlePressed: addCompanyPressed),
              ],
            ),
          ),
        ));
  }

  void addCompanyPressed() {
    // 회사 추가 요청
    if (_companyNameController.text == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) => const OneButtonDialog(
          content: "회사명을 입력해주세요.",
        ),
      );

      return;
    } else if (_bnoController.text == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) => const OneButtonDialog(
          content: "사업자 등록번호를 입력해주세요.",
        ),
      );

      return;
    } else if (_domainController.text == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) => const OneButtonDialog(
          content: "사내메일 도메인을 입력해주세요.",
        ),
      );

      return;
    } else if (!RegExp('@[a-zA-Z0-9-]+.[a-zA-Z]+')
        .hasMatch(_domainController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const OneButtonDialog(
          content: "도메인 형식이 올바르지 않습니다.",
        ),
      );
      return;
    }
    try {
      waitAddCompany(context, _companyNameController.text, _bnoController.text,
          _domainController.text.substring(1)); // 첫 문자 '@' 제외하고 요청
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return OneButtonDialog(content: "요청 실패: $error");
        },
      );
    }
  }
}

void waitAddCompany(
    BuildContext context, String companyName, String bno, String domain) async {
  print('추가요청 pressed: $companyName, $bno, $domain');
  Map<String, dynamic> res = await addCompany(companyName, bno, domain);
  if (res['success'] == true) {
    // 요청 성공
    print(res);
    showDialog(
      context: context,
      builder: (context) => const OneButtonDialog(
        content: "회사 추가 요청 성공! 회사가 승인될 때까지 기다려주세요.",
      ),
    );
  } else {
    // 요청 실패
    showDialog(
      context: context,
      builder: (BuildContext context) => OneButtonDialog(
        content: "회사 추가요청 실패: ${res['message']}(${res['statusCode']})",
      ),
    );
  }
}
