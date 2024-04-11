import 'package:flutter/material.dart';
import 'package:frontend/screen/verify_company_screen.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/search_textfield.dart';

class SearchCompanyScreen extends StatefulWidget {
  const SearchCompanyScreen({super.key});

  @override
  _SearchCompanyScreenState createState() => _SearchCompanyScreenState();
}

class _SearchCompanyScreenState extends State<SearchCompanyScreen> {
  final TextEditingController _companyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '회사 등록',
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
                Text("재직 중인 회사를 선택해주세요.",
                    style: TextStyle(
                      fontSize: 20,
                    )),
              ]),
              const SizedBox(
                height: 20,
              ),
              // 입력창
              SearchTextfield(
                hintText: null,
                controller: _companyNameController,
                onSearch: companyPressed,
              ),
              const SizedBox(
                height: 10,
              ),
            ])));
  }

  void companyPressed(String companyName) {
    if (companyName == '') {
      showAlertDialog(context, '회사 이름을 입력해주세요.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyCompanyScreen(companyName: companyName),
      ),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }
}
