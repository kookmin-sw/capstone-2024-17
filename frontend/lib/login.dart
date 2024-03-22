import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext ctx) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.close),
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              kakaoLogin(context);
            },
            child: const Text('카카오톡으로 로그인'),
          ),
        ),
      );
    });
  }
}

void kakaoLogin(BuildContext context) async {
  // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
  if (await isKakaoTalkInstalled()) {
    try {
      await UserApi.instance.loginWithKakaoTalk();
      debugPrint('isKakaoTalkInstalled: 카카오톡으로 로그인 성공');
    } catch (error) {
      debugPrint('isKakaoTalkInstalled: 카카오톡으로 로그인 실패 $error');

      // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
      // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
      if (error is PlatformException && error.code == 'CANCELED') {
        return;
      }
      // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
      try {
        await UserApi.instance.loginWithKakaoAccount();
        debugPrint('isKakaoTalkInstalled: 카카오계정으로 로그인 성공');
      } catch (error) {
        debugPrint('isKakaoTalkInstalled: 카카오계정으로 로그인 실패 $error');
      }
    }
  } else {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      debugPrint('카카오계정으로 로그인 성공');
    } catch (error) {
      debugPrint('카카오계정으로 로그인 실패 $error');
    }
  }
  ;
}
