import 'package:flutter/material.dart';
import 'package:frontend/notification.dart';
import 'package:frontend/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/model/user_profile_model.dart';
import 'package:provider/provider.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<String?> login(BuildContext context) async {
    UserProfileModel userProfile =
        Provider.of<UserProfileModel>(context, listen: false);
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        // 카카오톡이 설치되어있음
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡이 설치되어있지 않음
        // 카카오계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      Map<String, dynamic> res = await kakaoLogin(token.accessToken);
      if (res['success'] == true) {
        // 요청 성공
        const storage = FlutterSecureStorage();
        await storage.write(key: 'authToken', value: res["data"]["authToken"]);
        updateNotificationLogFile(res['data']['userUUID']); // 알림 기록 파일 업데이트

// 유저 정보 가져오기
        getUserDetail().then((userDetail) {
          print('[login getuserdetail] $userDetail');
          userProfile.setProfile(
            userId: userDetail['data']['userId'],
            nickname: userDetail['data']['nickname'],
            logoUrl: (userDetail['data']['company'] != null)
                ? userDetail['data']['company']['logoUrl']
                : '',
            company: (userDetail['data']['company'] != null)
                ? userDetail['data']['company']['name']
                : '미인증',
            position: userDetail['data']['position'],
            introduction: userDetail['data']['introduction'] ?? '',
            rating: userDetail['data']['coffeeBean'],
          );
        });
        // 메인 페이지로 navigate, 스택에 쌓여있던 페이지들 삭제
        Future.delayed(Duration.zero, () {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        });
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
