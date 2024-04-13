import 'package:flutter/material.dart';
import 'package:frontend/screen/verify_company_screen.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/company_item.dart';
import 'package:frontend/widgets/search_textfield.dart';

class SearchCompanyScreen extends StatefulWidget {
  const SearchCompanyScreen({super.key});

  @override
  _SearchCompanyScreenState createState() => _SearchCompanyScreenState();
}

class _SearchCompanyScreenState extends State<SearchCompanyScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  List<Map<String, dynamic>> companyList = [];

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
            // alignment: Alignment.center,
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
                onSearch: searchPressed,
              ),

              const SizedBox(
                height: 10,
              ),

              //
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children:
                      /*
                  const <Widget>[
                    CompanyItem(
                      // id: 1,
                      companyName: '네이버',
                      // logoImage: Image.asset("assets/logo.png"),
                    ),
                    CompanyItem(
                      // id: 2,
                      companyName: '카카오',
                      // logoImage: Image.asset("assets/coffee_bean.png"),
                    ),
                  ]
                  */

                      _buildCompanyItems(),
                ),
              ),
            ])));
  }

  void searchPressed(String companyName) {
    if (companyName == '') {
      showAlertDialog(context, '회사 이름을 입력해주세요.');
      return;
    }
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyCompanyScreen(companyName: companyName),
      ),
    );
    */
    getCompanyList();
  }

  List<Widget> _buildCompanyItems() {
    return companyList.map((company) {
      // int companyId = company['companyId'];
      String companyName = company['companyName'];
      // Image logoImage = company['logoImage'];
      return CompanyItem(
        // id: id,
        companyName: companyName,
        // logoImage: null, // 일단 null로 설정
      );
    }).toList();
  }

  // 입력된 값에 따른 회사정보 목록 get
  Future<void> getCompanyList() async {
    // 임시값
    companyList = [
      {'companyName': 'NAVER'},
      {'companyName': '카카오'},
      {
        'companyName':
            'Googleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
      },
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
      {'companyName': 'Google'},
    ];
    setState(() => {});
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }
}
