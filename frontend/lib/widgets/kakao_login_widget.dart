import 'package:flutter/material.dart';
import 'package:frontend/kakao_login.dart';
import 'package:frontend/login_view_model.dart';
import 'package:frontend/model/user_model2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KakaoLoginWidget extends StatelessWidget {
  const KakaoLoginWidget(this.onPressed, {super.key});
  final VoidCallback onPressed; // 상위 위젯에게 자신이 press됐음을 알리기 위한 콜백함수
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    LoginViewModel loginViewModel = Provider.of<LoginViewModel>(context);
    return InkWell(
      onTap: () async {
        UserModel2 user = await KakaoLogin().login();
        loginViewModel.login(user);
        await storage.write(key: 'userUUID', value: '카톡');
        await storage.write(key: 'authToken', value: '카톡토큰');
        onPressed(); // await이 끝나면 콜백함수를 돌려준다
      },
      child: Container(
        width: 170,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            fit: BoxFit.fitWidth,
            image: AssetImage('assets/kakao_login_medium_narrow.png'),
          ),
        ),
      ),
    );
  }
}
