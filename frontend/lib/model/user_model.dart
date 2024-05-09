class UserModel {
  final String loginId;
  String nickname;
  String company;
  String position;
  String introduction;
  double rating;

  UserModel.fromJson(Map<String, dynamic> json)
      : loginId = json['loginId'],
        nickname = json['nickname'],
        company = json['company'],
        position = json['position'],
        introduction = json['introduction'],
        rating = double.parse(json['coffeeBean']);
}
