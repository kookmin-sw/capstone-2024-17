import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';

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
  final TextEditingController _companyNameController = TextEditingController();

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
              Text("회사: ${widget.companyName}"),
              // 이메일 전송 텍스트 필드
              // 인증번호 입력 텍스트 필드(+타이머)
            ])));
  }
}
