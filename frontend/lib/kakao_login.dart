import 'package:frontend/social_login.dart';
import 'package:frontend/user_model.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<UserModel> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        // 카카오톡이 설치되어있음
        // 카카오톡으로 로그인
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡이 설치되어있지 않음
        // 카카오계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }
    } catch (error) {
      return UserModel('', '', '');
    }

    final User user = await UserApi.instance.me();
    final String? nickname = user.kakaoAccount?.profile?.nickname;

    return UserModel('', nickname ?? '', 'kakao');
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
