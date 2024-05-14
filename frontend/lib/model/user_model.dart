class UserModel {
  int userId;
  String nickname;
  String company;
  String position;
  String introduction;
  double rating;

  UserModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        nickname = json['nickname'],
        company = json['company'],
        position = json['position'],
        introduction = json['introduction'],
        rating = double.parse(json['coffeeBean']);
}
