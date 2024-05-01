import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/top_appbar.dart';

class OptionItem extends StatelessWidget {
  final String optionName;
  final String optionRouteName;

  const OptionItem({
    super.key,
    required this.optionName,
    required this.optionRouteName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero, () {
            Navigator.pushNamed(context, optionRouteName);
          });
        },
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: Card(
                  elevation: 0,
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(optionName,
                          style: const TextStyle(
                            fontSize: 18,
                          )))),
            )
          ]),
          const Row(children: <Widget>[Expanded(child: Divider())]),
        ]));
  }
}

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final storage = const FlutterSecureStorage();

  final List<Map<String, String>> optionList = [
    {
      'optionName': '옵션1',
      'optionRouteName': '/option1',
    },
    {
      'optionName': '옵션2',
      'optionRouteName': '/option2',
    },
    {
      'optionName': '옵션3',
      'optionRouteName': '/option3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: "환경설정",
      ),
      body: Center(
          child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              child: Column(children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: _buildOptionItems(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // 로그아웃 버튼
                    TextButton(
                      onPressed: () async {
                        await logout(context).then((_) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/user', (route) => false);
                        });
                      },
                      child: const Text('로그아웃'),
                    ),
                    const Text('|'),
                    // 회원 탈퇴 버튼
                    TextButton(
                      onPressed: () async {},
                      child: const Text('회원 탈퇴'),
                    ),
                  ],
                ),
                const Text(
                  '앱 버전: 1.0.0',
                ),
              ]))),
      bottomNavigationBar: const BottomAppBar(),
    );
  }

  List<Widget> _buildOptionItems() {
    return optionList.map((option) {
      String optionName = option['optionName']!;
      String optionRouteName = option['optionRouteName']!;
      return OptionItem(
        optionName: optionName,
        optionRouteName: optionRouteName,
      );
    }).toList();
  }

  Future<void> logout(BuildContext context) async {
    await storage.deleteAll();
    return;
  }
}
