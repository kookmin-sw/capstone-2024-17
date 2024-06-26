import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/model/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const baseUrl = "http://3.36.108.21:8080";
const storage = FlutterSecureStorage();

// 주변 카페에 있는 모든 유저 목록 받아오기 - http post 요청
Future<Map<String, List<UserModel>>> getAllUsers(
    String userToken, List<String> cafeList, int userId) async {
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

    print("!!!!!getAllUsers response: $jsonResult");

    jsonResult.forEach((cafe, userList) {
      List<Map<String, dynamic>> userMapList =
          userList.cast<Map<String, dynamic>>();
      allUsers[cafe] = userMapList
          .where((user) => user["userId"] != userId)
          .map((user) => UserModel.fromJson(user))
          .toList();
    });

    return allUsers;
  } catch (error) {
    print("HTTP POST error (getAllUsers) : $error");
    throw Exception();
  }
}

// 커피챗 매칭 정보 가져오기 (진행중 여부, 내/상대방 정보)
Future<Map<String, dynamic>> getMatchingInfo(userId) async {
  final url =
      Uri.parse('$baseUrl/match/isMatching?userId=$userId'); // check !!!
  String? userToken = await storage.read(key: "authToken");

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      if (responseData['success']) {
        var isMatching = responseData["data"]["isMatching"] == "yes";
        // 진행중이 아니면 - 진행중 여부만 반환
        if (!isMatching) {
          return {"isMatching": isMatching};
        }
        // 진행중이면 - 전체(진행중 여부, 매칭 정보) 반환
        var matchPosition =
            responseData["data"]["matchPosition"]; // "sender" or "receiver"
        var myInfo = responseData["data"]["${matchPosition}Info"];
        var myId = myInfo["${matchPosition}Id"];
        var partnerInfo = (matchPosition == "sender")
            ? responseData["data"]["receiverInfo"]
            : responseData["data"]["senderInfo"];
        var partnerId = (matchPosition == "sender")
            ? partnerInfo["receiverId"]
            : partnerInfo["senderId"];
        return {
          "isMatching": isMatching,
          "matchId": responseData["data"]["matchId"],
          "myId": myId,
          "myNickname": myInfo["nickname"],
          "myCompany": myInfo["company"]["name"],
          "partnerId": partnerId,
          "partnerCompany": partnerInfo["company"]["name"],
          "partnerNickname": partnerInfo["nickname"],
        };
      } else {
        throw Exception('${responseData["message"]}(${responseData["code"]})');
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode} ${response.body}');
    }
  } catch (error) {
    print("HTTP GET error (getIsMatching) : $error");
    throw Exception();
  }
}

//매칭 요청
Future<Map<String, dynamic>> matchRequest(
    int senderId, int receiverId, int requestTypeId) async {
  final url = Uri.parse('$baseUrl/match/request');
  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
        'requestTypeId': requestTypeId
      }),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      if (responseData['success']) {
        print(responseData);
        return responseData;
      } else {
        throw Exception(
            '매칭 요청이 실패했습니다: ${responseData["message"]}(${responseData["code"]})');
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP POST error (matchRequest) : $error");
    throw Exception();
  }
}

//매칭 info 요청//보낸 요청
Future<Map<String, dynamic>> requestInfoRequest(int senderId) async {
  final url = Uri.parse('$baseUrl/match/request/info?senderId=$senderId');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get match info: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP GET error (requestInfoRequest) : $error");
    throw Exception();
  }
}

//매칭 요청 받은 list
Future<List<Map<String, dynamic>>> receivedInfoRequest(int receiverId) async {
  final url = Uri.parse('$baseUrl/match/received/info?receiverId=$receiverId');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
    );

    if (response.statusCode == 200) {
      // 응답 데이터가 리스트 형식인지 확인하고, 맞다면 그대로 반환
      List<dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes))["data"];
      print(responseData.runtimeType); // 출력: String

      List<Map<String, dynamic>> resultList =
          responseData.cast<Map<String, dynamic>>();
      return resultList;
    } else {
      throw Exception(
          'Failed to get receivedInfoRequest: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP GET error (receivedInfoRequest) : $error");
    throw Exception();
  }
}

//match cancel 요청
Future<Map<String, dynamic>> matchCancelRequest(String matchId) async {
  final url = Uri.parse('$baseUrl/match/cancel');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({
        'matchId': matchId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get match info: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP PUT error (matchCancelRequest) : $error");
    throw Exception();
  }
}

//match accept  요청
Future<Map<String, dynamic>> matchAcceptRequest(String matchId) async {
  final url = Uri.parse('$baseUrl/match/accept');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({
        'matchId': matchId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get match accept: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP PUT error (matchAcceptRequest) : $error");
    throw Exception();
  }
}

//match decline  요청
Future<Map<String, dynamic>> matchDeclineRequest(String matchId) async {
  final url = Uri.parse('$baseUrl/match/decline');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({
        'matchId': matchId,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get match delete: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP PUT error (matchDeclineRequest) : $error");
    throw Exception();
  }
}

//match finish  요청
Future<Map<String, dynamic>> matchFinishRequest(
    String matchId, int enderId) async {
  final url = Uri.parse('$baseUrl/match/finish');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({
        'matchId': matchId,
        'enderId': enderId,
      }),
    );
    if (response.statusCode == 200) {
      print("삭제성공");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get match delete: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP PUT error (matchFinishRequest) : $error");
    throw Exception();
  }
}

//커피챗 진행 후 평점 보내기
Future<Map<String, dynamic>> coffeeBeanReview(
    String matchId, int reviewerId, int revieweeId, int rating) async {
  final url = Uri.parse('$baseUrl/match/review');
  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
      body: jsonEncode({
        "matchId": matchId,
        "reviewerId": reviewerId,
        "revieweeId": revieweeId,
        "rating": rating,
        "comment": ""
      }),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      if (responseData['success']) {
        return responseData;
      } else {
        throw Exception(
            '매칭 요청이 실패했습니다: ${responseData["message"]}(${responseData["code"]})');
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP POST error (coffeeBeanReview) : $error");
    throw Exception();
  }
}

Future<Map<String, dynamic>> checkReviewedRequest(
    String matchId, int enderId) async {
  final url = Uri.parse(
      '$baseUrl/match/check/reviewed?matchId=$matchId&enderId=$enderId');

  String? userToken = await storage.read(key: 'authToken');

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get reviewed info: ${response.statusCode}');
    }
  } catch (error) {
    print("HTTP GET error (checkReviewedRequest) : $error");
    throw Exception();
  }
}

// 회원가입
Future<Map<String, dynamic>> signup(String? loginId, String? password,
    String nickname, String email, String phone) async {
  // 디바이스 토큰을 발급
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  // print('!!!디바이스 토큰!!!!!: $fcmToken');
  final url = Uri.parse('$baseUrl/auth/signUp');
  final data = jsonEncode({
    'loginId': loginId,
    'password': password,
    'nickname': nickname,
    'email': email,
    'phone': phone,
    'deviceToken': fcmToken,
  });
  try {
    http.Response res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('HTTP POST error (signup) : $error');
    throw Exception();
  }
}

// 로그인
Future<Map<String, dynamic>> login(String loginId, String password) async {
  // 디바이스 토큰을 발급
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  final url = Uri.parse('$baseUrl/auth/signIn');
  final data = jsonEncode({
    'loginId': loginId,
    'password': password,
    'deviceToken': fcmToken,
  });
  try {
    http.Response res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('HTTP POST error (login) : $error');
    throw Exception();
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
    print('HTTP GET error (getUserDetail) : $error');
    throw Exception();
  }
}

// 유저 delete: 유저 정보 get(임시)해서 가져온 userUUID로 진행
Future<Map<String, dynamic>> deleteUser() async {
  final url = Uri.parse('$baseUrl/auth/delete');
  final token = (await storage.read(key: 'authToken')) ?? '';
  Map<String, dynamic> res1 = await getUserDetail();
  if (res1['success'] == true) {
    final userUUID = res1['data']['userUUID'];
    final data = jsonEncode({
      'userUUID': userUUID,
    });
    try {
      http.Response res2 = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: data,
      );
      Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res2.bodyBytes));
      return jsonData;
    } catch (error) {
      print('HTTP DELETE error (deleteUser) : $error');
      throw Exception();
    }
  } else {
    // UUID 가져오기 실패
    print('유저 정보 get 도중 에러 발생');
    throw Exception();
  }
}

// 닉네임 업데이트
Future<Map<String, dynamic>> updateNickname(String nickname) async {
  final url = Uri.parse('$baseUrl/user/nickname/update');
  final token = (await storage.read(key: 'authToken')) ?? '';
  final data = jsonEncode({
    'nickname': nickname,
  });
  try {
    http.Response res = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('HTTP POST error (updateNickname) : $error');
    throw Exception();
  }
}

// 자기소개 업데이트
Future<Map<String, dynamic>> updateIntroduction(String introduction) async {
  final url = Uri.parse('$baseUrl/user/introduction/update');
  final token = (await storage.read(key: 'authToken')) ?? '';
  final data = jsonEncode({
    'introduction': introduction,
  });
  try {
    http.Response res = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('HTTP POST error (updateIntroduction) : $error');
    throw Exception();
  }
}

// 회사 초기화
Future<Map<String, dynamic>> resetCompany() async {
  final url = Uri.parse('$baseUrl/user/company/reset');
  final token = (await storage.read(key: 'authToken')) ?? '';
  try {
    http.Response res = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('HTTP PUT error (resetCompany) : $error');
    throw Exception();
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
    print('HTTP GET error (getChatroomlist) : $error');
    throw Exception();
  }
}

// 직무리스트 가져오기
Future<Map<String, dynamic>> getPositionlist() async {
  final url = Uri.parse('$baseUrl/user/position/list');
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
    print('HTTP GET error (getPositionlist) : $error');
    throw Exception();
  }
}

// 직무 저장 요청
Future<Map<String, dynamic>> updatePosition(String position) async {
  final url = Uri.parse('$baseUrl/user/position/update');
  final token = (await storage.read(key: 'authToken')) ?? '';
  final data = jsonEncode({
    'position': position,
  });
  try {
    http.Response res = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('HTTP POST error (updatePosition) : $error');
    throw Exception();
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
    print('HTTP GET error (getChatList) : $error');
    throw Exception();
  }
}

// 카카오톡 로그인
Future<Map<String, dynamic>> kakaoLogin(String token) async {
  // 디바이스 토큰을 발급
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  final url = Uri.parse('$baseUrl/auth/kakaoSignIn');
  final data = jsonEncode({
    'accessToken': token,
    'deviceToken': fcmToken,
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
    print('HTTP POST error (kakaoLogin) : $error');
    throw Exception();
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
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    return jsonData;
  } catch (error) {
    print('HTTP GET error (getCompanyList) : $error');
    throw Exception();
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
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('HTTP POST error (verificationRequest) : $error');
    throw Exception();
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
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('HTTP POST error (verification) : $error');
    throw Exception();
  }
}

// 회사 등록
Future<Map<String, dynamic>> addCompany(
    String companyName, String bno, String domain) async {
  final url = Uri.parse('$baseUrl/company/request');
  final token = (await storage.read(key: 'authToken')) ?? '';
  final data = jsonEncode({
    'name': companyName,
    'domain': domain,
    'bno': bno,
  });
  try {
    http.Response res = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: data);
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(res.bodyBytes));
    print(jsonData);
    return jsonData;
  } catch (error) {
    print('HTTP POST error (addCompany) : $error');
    throw Exception();
  }
}
