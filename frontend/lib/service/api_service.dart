import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/model/user_model.dart';

const baseUrl = "http://3.36.108.21:8080";
const storage = FlutterSecureStorage();

// 주변 카페에 있는 모든 유저 목록 받아오기 - http post 요청
Future<Map<String, List<UserModel>>> getAllUsers(
    String userToken, List<String> cafeList) async {
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

// 유저 정보 get
Future<Map<String, dynamic>> getUserDetail() async {
  final url = Uri.parse('$baseUrl/auth/detail');
  final token = (await storage.read(key: 'authToken')) ?? '';
  try {
    http.Response res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 유저의 채팅방 목록 get: 해당 유저는 토큰으로 판단
Future<Map<String, dynamic>> getChatroomlist() async {
  final url = Uri.parse('$baseUrl/chatroom/list');
  final token = (await storage.read(key: 'authToken')) ?? '';
  // print("토큰은: $token");
  try {
    http.Response res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 해당 채팅방의 채팅 목록을 get
Future<Map<String, dynamic>> getChatList(int chatroomId) async {
  const endpointUrl = '$baseUrl/message/list';

  String queryString = Uri(queryParameters: {
    'chatroom_id': chatroomId.toString(),
  }).query;
  final url = '$endpointUrl?$queryString';

  final token = (await storage.read(key: 'authToken')) ?? '';
  try {
    http.Response res = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
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
    http.Response res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: data,
    );
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 키워드로 회사 검색
Future<Map<String, dynamic>> getCompanyList(String companyKeyword) async {
  const endpointUrl = '$baseUrl/company/search';
  String queryString = Uri(queryParameters: {
    'keyword': companyKeyword,
  }).query;
  final url = '$endpointUrl?$queryString';
  try {
    http.Response res = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(res.body);
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 이메일 전송
Future<Map<String, dynamic>> verificationRequest(String email) async {
  final url = Uri.parse('$baseUrl/email/verification-request');
  final token = (await storage.read(key: 'authToken')) ?? '';
  print('토큰: $token');
  final data = jsonEncode({
    'email': email,
  });
  try {
    http.Response res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: data,
    );
    Map<String, dynamic> jsonData = jsonDecode(res.body);
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 인증코드로 인증
Future<Map<String, dynamic>> verification(String email, String authCode) async {
  final url = Uri.parse('$baseUrl/email/verification');
  final token = (await storage.read(key: 'authToken')) ?? '';
  final data = jsonEncode({
    'email': email,
    'authCode': authCode,
  });
  try {
    http.Response res = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: data);
    Map<String, dynamic> jsonData = jsonDecode(res.body);
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}

// 회사 등록
Future<Map<String, dynamic>> addCompany(
    String companyName, String bno, String domain) async {
  final url = Uri.parse('$baseUrl/company/request');
  final data = jsonEncode({
    'name': companyName,
    'domain': domain,
    'bno': bno,
  });
  try {
    http.Response res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('error: $error');
    throw Error();
  }
}
