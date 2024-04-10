import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/model/user_model.dart';

// 임의로 baseUrl 지정 (추후 서버 주소로 변경 필요)
const baseUrl = "https://localhost:8080";

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