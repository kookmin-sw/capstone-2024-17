import 'package:frontend/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/api_service.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<String?> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        // 카카오톡이 설치되어있음
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
        // print('카카오톡으로 로그인: ${token.accessToken}');
      } else {
        // 카카오톡이 설치되어있지 않음
        // 카카오계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
        // print('카카오계정으로 로그인: ${token.accessToken}');
      }
      Map<String, dynamic> res = await kakaoLogin(token.accessToken);
      if (res['success'] == true) {
        // 요청 성공
        const storage = FlutterSecureStorage();
        await storage.write(key: 'authToken', value: res["data"]["authToken"]);
      } else {
        // 실패
        print('카카오 로그인 실패: ${res['message']}(${res['code']})');
      }
    } catch (error) {
      print('카카오 로그인 에러: $error');
      return null;
    }

    final User user = await UserApi.instance.me();
    final String? nickname = user.kakaoAccount?.profile?.nickname;

    return nickname;
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
