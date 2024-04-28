import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '설정',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 로그아웃 버튼
              ElevatedButton(
                onPressed: () async {
                  await logout(context).then((_) { 
                     Navigator.pushNamedAndRemoveUntil(context, '/user', (route) => false);
                  });
                },
                child: const Text('로그아웃'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await storage.deleteAll();
    return;
  }
}