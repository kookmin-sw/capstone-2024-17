import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/model/user_model.dart';

const baseUrl = "http://43.203.218.27:8080";
const userToken =
    "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsImV4cCI6MTcxMzU5OTA5NiwiaWQiOjF9.HSC3z5gus1gM0DavxjZdhVBZSlUCGhgEbjIYS2-bKng";

// 주변 카페에 있는 모든 유저 목록 받아오기 - http post 요청
Future<Map<String, List<UserModel>>> getAllUsers(List<String> cafeList) async {
  try {
    final url = Uri.parse("$baseUrl/cafe/get-users");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({"cafeList": cafeList}),
    );

    Map<String, List<UserModel>> allUsers = {};
    Map<String, dynamic> jsonResult =
        jsonDecode(utf8.decode(response.bodyBytes));

    jsonResult.forEach((cafe, userList) {
      List<Map<String, dynamic>> userMapList =
          userList.cast<Map<String, dynamic>>();
      allUsers[cafe] =
          userMapList.map((user) => UserModel.fromJson(user)).toList();
    });

    return allUsers;
  } catch (error) {
    print("HTTP POST error: $error");
    throw Error();
  }
}

// 회원가입
Future<Map<String, dynamic>> signup(String? loginId, String? password,
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
    print(jsonData);
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

// 카카오톡 로그인
Future<Map<String, dynamic>> kakaoLogin(String token) async {
  final url = Uri.parse('$baseUrl/auth/kakaoSignIn');
  final data = jsonEncode({
    'accessToken': token,
  });
  try {
    http.Response res = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}
