class UserModel {
  final int userId;
  String nickname;
  String companyName;
  String positionName;
  String introduction;

  UserModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        nickname = json['nickname'],
        companyName = json['companyName'],
        positionName = json['positionName'],
        introduction = json['introduction'];
}
