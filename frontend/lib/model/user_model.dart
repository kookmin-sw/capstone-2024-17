class UserModel {
  final int userId;
  final String nickname;
  final String companyName;
  final String positionName;
  final String introduction;

  UserModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        nickname = json['nickname'],
        companyName = json['companyName'],
        positionName = json['positionName'],
        introduction = json['introduction'];
}
