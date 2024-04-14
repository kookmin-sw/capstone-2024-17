import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/model/user_model.dart';

// 임의로 baseUrl 지정 (추후 서버 주소로 변경 필요)
const baseUrl = "https://localhost:8080";

// 주변 카페에 있는 유저 목록 POST 요청으로 받아오기
Future<Map<String, List<UserModel>>> getAllUsers(List<String> cafeList) async {
  final url = Uri.parse("$baseUrl/cafe");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({cafeList: cafeList}),
  );

  if (response.statusCode == 200) {
    Map<String, List<UserModel>> allUsers = {};
    Map<String, dynamic> jsonResult = jsonDecode(response.body);

    jsonResult.forEach((cafe, userList) {
      allUsers[cafe] =
          userList.map((user) => UserModel.fromJson(user)).toList();
    });

    return allUsers;
  }
  throw Error();
}
