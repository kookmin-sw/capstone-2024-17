import 'package:frontend/service/api_service.dart';
import 'package:flutter/material.dart';
// import 'package:frontend/screen/verify_company_screen.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/company_item.dart';
import 'package:frontend/widgets/search_textfield.dart';

class SearchCompanyScreen extends StatefulWidget {
  const SearchCompanyScreen({super.key});

  @override
  _SearchCompanyScreenState createState() => _SearchCompanyScreenState();
}

class _SearchCompanyScreenState extends State<SearchCompanyScreen> {
  final TextEditingController _companyKeywordController =
      TextEditingController();
  // List<Map<String, dynamic>> companyList = [];
  // 검색 이전: 테스트를 위한 임의의 데이터
  List<Map<String, dynamic>> companyList = [
    {
      'name': 'NAVER',
      'logoUrl':
          'https://capstone2024-17-coffeechat.s3.ap-northeast-2.amazonaws.com/coffeechat-logo.png'
    },
    {
      'name': '카카오',
      'logoUrl':
          'https://capstone2024-17-coffeechat.s3.ap-northeast-2.amazonaws.com/coffeechat-logo.png'
    },
    {
      'name': 'Google',
      'logoUrl':
          'https://images.unsplash.com/photo-1572059002053-8cc5ad2f4a38?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
    },
  ];

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
                controller: _companyKeywordController,
                onSearch: searchPressed,
              ),

              const SizedBox(
                height: 10,
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: companyList.isEmpty
                      ? [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(60),
                            child: const Text('검색 결과가 없습니다.'),
                          ),
                        ]
                      : _buildCompanyItems(),
                ),
              ),
            ])));
  }

  void searchPressed(String keyword) async {
    if (keyword == '') {
      showAlertDialog(context, '회사 이름을 입력해주세요.');
      return;
    }
    waitGetCompanyList(keyword);
  }

  List<Widget> _buildCompanyItems() {
    return companyList.map((company) {
      String companyName = company['name'];
      String logoInfo = company['logoUrl'];
      return CompanyItem(
        companyName: companyName,
        logoInfo: logoInfo,
      );
    }).toList();
  }

  // 입력된 값에 따른 회사정보 목록 받아오기
  Future<void> waitGetCompanyList(String keyword) async {
    try {
      Map<String, dynamic> res = await getCompanyList(keyword);
      print(res);
      if (res['success']) {
        // 요청 성공
        setState(() {
          companyList = List<Map<String, dynamic>>.from(res['data']);
        });
      } else {
        // 예외처리
        print('회사정보 검색 실패: ${res["message"]}(${res["statusCode"]})');
        showAlertDialog(
          context,
          '회사정보 검색 실패: ${res["message"]}(${res["statusCode"]})',
        );
      }
    } catch (error) {
      print('회사정보 검색 실패: $error');
      showAlertDialog(context, '회사정보 검색 실패: $error');
    }

    setState(() => {});
  }

  @override
  void dispose() {
    _companyKeywordController.dispose();
    super.dispose();
  }
}
