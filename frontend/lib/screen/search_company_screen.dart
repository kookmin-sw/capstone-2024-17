import 'package:frontend/screen/add_company_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:flutter/material.dart';
// import 'package:frontend/screen/verify_company_screen.dart';
import 'package:frontend/widgets/company_item.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/search_textfield.dart';
import 'package:frontend/widgets/top_appbar.dart';

class SearchCompanyScreen extends StatefulWidget {
  const SearchCompanyScreen({super.key});

  @override
  _SearchCompanyScreenState createState() => _SearchCompanyScreenState();
}

class _SearchCompanyScreenState extends State<SearchCompanyScreen> {
  final TextEditingController _companyKeywordController =
      TextEditingController();
  final ScrollController _searchResultScrollController = ScrollController();
  // List<Map<String, dynamic>> companyList = [];
  // 검색 이전: 테스트를 위한 임의의 데이터
  List<Map<String, dynamic>> companyList = [
    /*
    {
      'name': '국민대',
      'logoUrl':
          'https://capstone2024-17-coffeechat.s3.ap-northeast-2.amazonaws.com/coffeechat-logo.png',
      'domain': 'kookmin.ac.kr'
    },
    {
      'name': 'NAVER',
      'logoUrl':
          'https://capstone2024-17-coffeechat.s3.ap-northeast-2.amazonaws.com/coffeechat-logo.png',
      'domain': 'naver.com'
    },
    {
      'name': 'Google',
      'logoUrl':
          'https://images.unsplash.com/photo-1572059002053-8cc5ad2f4a38?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'domain': 'gmail.com'
    },
    */
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopAppBar(title: '회사 검색'),
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

              // 검색 결과
              Expanded(
                child: Scrollbar(
                  controller: _searchResultScrollController,
                  thumbVisibility: true,
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
              ),

              TextButton(
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCompanyScreen(),
                    ),
                  )
                },
                child: const Text('재직 중인 회사가 없어요!',
                    style: TextStyle(decoration: TextDecoration.underline)),
              )
            ])));
  }

  void searchPressed(String keyword) async {
    if (keyword == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first: '회사 이름을 입력해주세요.',
            ),
          );
        },
      );
      return;
    }
    waitGetCompanyList(keyword);
  }

  List<Widget> _buildCompanyItems() {
    return companyList.map((company) {
      String companyName = company['name'];
      String logoUrl = company['logoUrl'];
      String domain = company['domain'];
      return CompanyItem(
        companyName: companyName,
        logoUrl: logoUrl,
        domain: domain,
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: OneButtonDialog(
                first: '회사정보 검색 실패: ${res["message"]}(${res["statusCode"]})',
              ),
            );
          },
        );
      }
    } catch (error) {
      print('회사정보 검색 실패: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: OneButtonDialog(
              first: '회사정보 검색 실패: $error',
            ),
          );
        },
      );
    }

    setState(() => {});
  }

  @override
  void dispose() {
    _companyKeywordController.dispose();
    super.dispose();
  }
}
