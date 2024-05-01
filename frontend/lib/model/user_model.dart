class UserModel {
  final String loginId;
  String nickname;
  String companyName;
  String positionName;
  String introduction;
  int rating;

  UserModel.fromJson(Map<String, dynamic> json)
      : loginId = json['loginId'],
        nickname = json['nickname'],
        companyName = json['companyName'],
        positionName = json['positionName'],
        introduction = json['introduction'],
        rating = json['rating'];
}
