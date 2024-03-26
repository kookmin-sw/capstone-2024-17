import 'package:flutter/material.dart';
import 'package:frontend/kakao_login.dart';
import 'package:frontend/login_view_model.dart';
import 'package:frontend/user_model.dart';
import 'package:provider/provider.dart';

class KakaoLoginWidget extends StatelessWidget {
  const KakaoLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    LoginViewModel _loginViewModel = Provider.of<LoginViewModel>(context);
    return InkWell(
      onTap: () async {
        UserModel user = await KakaoLogin().login();
        _loginViewModel.login(user.name ?? '', 'kakao');
        // print('KakaoLogin() 완료! 이름: ${_loginViewModel.name}');
      },
      child: Image.asset('assets/kakao_login_medium_narrow.png'),
    );
    ;
  }
}
