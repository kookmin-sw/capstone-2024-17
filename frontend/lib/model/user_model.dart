class UserModel {
  final int loginId;
  String nickname;
  String companyName;
  String positionName;
  String introduction;

  UserModel.fromJson(Map<String, dynamic> json)
      : loginId = json['loginId'],
        nickname = json['nickname'],
        companyName = json['companyName'],
        positionName = json['positionName'],
        introduction = json['introduction'];
}
