import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/model/user_model.dart';

const baseUrl = "http://43.203.218.27:8080";

// 주변 카페에 있는 유저 목록 POST 요청으로 받아오기
Future<Map<String, List<UserModel>>> getAllUsers(List<String> cafeList) async {
  final url = Uri.parse("$baseUrl/cafe/get-users");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"cafeList": cafeList}),
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

// 회원가입
Future<Map<String, dynamic>> signup(String loginId, String password,
    String nickname, String email, String phone) async {
  final url = Uri.parse('$baseUrl/auth/signUp');
  final data = jsonEncode({
    'loginId': loginId,
    'password': password,
    'nickname': nickname,
    'email': email,
    'phone': phone,
  });
  try {
    http.Response res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: data);
    Map<String, dynamic> jsonData = jsonDecode(res.body);
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 로그인
Future<Map<String, dynamic>> login(
    String loginId,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signIn');
    final data = jsonEncode({
      'loginId': loginId,
      'password': password,
    });
    try {
      http.Response res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      return jsonData;
    } catch (error) {
      print('error: $error');
      throw Error();
    }
  }

