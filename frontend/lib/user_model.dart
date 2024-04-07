class UserModel {
  final String loginId;
  final String nickname;
  final String loginType; // none, kakao, ...

  UserModel(this.loginId, this.nickname, this.loginType);
}
