import 'package:flutter/material.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/service/auto_offline_service.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/top_appbar.dart';

class OptionItem extends StatelessWidget {
  final String optionName;
  final IconData optionIconData;
  final String optionRouteName;

  const OptionItem({
    super.key,
    required this.optionName,
    required this.optionIconData,
    required this.optionRouteName,
  });

/*
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(optionName),
      leading: Icon(optionIconData),
      onTap: () {
        Future.delayed(Duration.zero, () {
          Navigator.pushNamed(context, optionRouteName);
        });
      },
    );
  }
*/

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
                    child: Row(children: <Widget>[
                      Icon(optionIconData, color: Colors.grey),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(optionName,
                          style: const TextStyle(
                            fontSize: 17,
                          )),
                    ])),
              ),
            )
          ]),
          const Row(children: <Widget>[Expanded(child: Divider())]),
        ]));
  }
}

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final storage = const FlutterSecureStorage();

  final List<Map<String, dynamic>> optionList = [
    {
      'optionName': '알림 설정',
      'optionIconData': Icons.notifications_none_rounded,
      'optionRouteName': '/option1',
    },
    {
      'optionName': '도움말',
      'optionIconData': Icons.help_outline_rounded,
      'optionRouteName': '/option2',
    },
    {
      'optionName': '앱 정보',
      'optionIconData': Icons.info_outline_rounded,
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
                vertical: 5,
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
                      onPressed: () async {
                        try {
                          Map<String, dynamic> res = await deleteUser();
                          if (res['success'] == true) {
                            // 요청 성공
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: OneButtonDialog(
                                    first: '탈퇴되었습니다.',
                                  ),
                                );
                              },
                            );

                            await logout(context).then((_) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/user', (route) => false);
                            });
                          } else {
                            // 회원탈퇴 실패

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: OneButtonDialog(
                                    first:
                                        '회원탈퇴 실패: ${res['message']}(${res['statusCode']})',
                                  ),
                                );
                              },
                            );
                          }
                        } catch (error) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: OneButtonDialog(
                                  first: '요청 실패: $error',
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: const Text('회원 탈퇴'),
                    ),
                  ],
                ),
                const Text(
                  '앱 버전: 1.0.0',
                ),
              ]))),
    );
  }

  List<Widget> _buildOptionItems() {
    return optionList.map((option) {
      String optionName = option['optionName']!;
      IconData optionIconData = option['optionIconData'];
      String optionRouteName = option['optionRouteName']!;
      return OptionItem(
        optionName: optionName,
        optionIconData: optionIconData,
        optionRouteName: optionRouteName,
      );
    }).toList();
  }

  Future<void> logout(BuildContext context) async {
    // 온라인 상태이면 오프라인으로 전환
    Provider.of<AutoOfflineService>(context, listen: false).autoOffline();

    // 기기에서 토큰 삭제
    await storage.deleteAll();
    return;
  }
}
