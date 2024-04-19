import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/model/user_model.dart';

// 임의로 baseUrl 지정 (추후 서버 주소로 변경 필요)
// const baseUrl = "https://localhost:8080";
const baseUrl = "http://43.203.218.27:8080";

// 카페에 있는 유저 목록 GET 요청
Future<List<UserModel>> getUserList(String cafeId) async {
  List<UserModel> userList = [];
  final url = Uri.parse("$baseUrl/cafe/$cafeId");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> users = jsonDecode(response.body);

    for (var user in users) {
      final userModel = UserModel.fromJson(user);
      userList.add(userModel);
    }
    return userList;
  }
  throw Error();
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

