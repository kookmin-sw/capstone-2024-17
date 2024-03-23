import 'package:frontend/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        // 카카오톡이 설치되어있음
        try {
          // 카카오톡으로 로그인
          await UserApi.instance.loginWithKakaoTalk();
          return true;
        } catch (error) {
          return false;
        }
      } else {
        // 카카오톡이 설치되어있지 않음
        try {
          // 카카오계정으로 로그인
          await UserApi.instance.loginWithKakaoAccount();
          return true;
        } catch (error) {
          return false;
        }
      }
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      return false;
    }
  }
}
