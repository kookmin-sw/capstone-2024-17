import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/service/stomp_service.dart';
import 'package:frontend/model/my_cafe_model.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
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
  late StompClient stompClient;
  late MyCafeModel myCafe;

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
    stompClient = Provider.of<StompClient>(context, listen: false);
    myCafe = Provider.of<MyCafeModel>(context);

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
                      onPressed: () async {
                        try {
                          Map<String, dynamic> res = await deleteUser();
                          if (res['success'] == true) {
                            // 요청 성공
                            showAlertDialog(context, '탈퇴되었습니다.)');
                            await logout(context).then((_) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/user', (route) => false);
                            });
                          } else {
                            // 회원탈퇴 실패
                            showAlertDialog(context,
                                '회원탈퇴 실패: ${res['message']}(${res['statusCode']})');
                          }
                        } catch (error) {
                          showAlertDialog(context, '요청 실패: $error');
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
      String optionRouteName = option['optionRouteName']!;
      return OptionItem(
        optionName: optionName,
        optionRouteName: optionRouteName,
      );
    }).toList();
  }

  Future<void> logout(BuildContext context) async {
    // 온라인 상태이면 오프라인으로 전환
    if (myCafe.cafeId != null) {
      int userId;
      Map<String, dynamic> res = await getUserDetail();

      if (res['success']) {
        userId = res['data']['userId'];
        print("!!!!유저 아이디: $userId");

        // pub 요청 - 카페 지정 해제
        deleteUserInCafe(
          stompClient,
          userId,
          myCafe.cafeId!,
        );
        myCafe.clearMyCafe();
      } else {
        print("!!!!유저 정보를 가져오는데 실패했습니다. ${res['message']}");
        return;
      }
    }

    // 기기에서 토큰 삭제
    await storage.deleteAll();
    return;
  }
}
