import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/iconed_textfield.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/top_appbar.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopAppBar(
          title: "회사 추가 요청",
        ),
        body: Container(
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
                        controller: _taxNumberController,
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
                  text: '회사 추가 요청하기', handlePressed: addRequestPressed),
            ],
          ),
        ),
        bottomNavigationBar: const BottomAppBar());
  }

  void addRequestPressed() {
    // 회원가입 진행
    if (_companyNameController.text == '') {
      showAlertDialog(context, '회사명을 입력해주세요.');
      return;
    } else if (_taxNumberController.text == '') {
      showAlertDialog(context, '사업자 등록번호를 입력해주세요.');
      return;
    } else if (_domainController.text == '') {
      showAlertDialog(context, '사내메일 도메인을 입력해주세요.');
      return;
    }
    try {
      waitAddRequest(context, _companyNameController.text,
          _taxNumberController.text, _domainController.text);
    } catch (error) {
      showAlertDialog(context, '요청 실패: $error');
    }
  }
}

void waitAddRequest(BuildContext context, String companyName, String taxNumber,
    String domain) async {
  print('추가요청 pressed: $companyName, $taxNumber, $domain');
  // 요청 코드
  /*
  Map<String, dynamic> res =
      await addRequest(companyName, taxNumber, domainController);
  if (res['success'] == true) {
    // 요청 성공
    print(res);
    showAlertDialog(context, res['message']);
  } else {
    // 요청 실패
    showAlertDialog(
        context, '회사 추가요청 실패: ${res['message']}(${res['statusCode']})');
  }
  */
}
