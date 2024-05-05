import 'dart:convert';

import 'package:frontend/model/user_model.dart';
import 'package:stomp_dart_client/stomp.dart';

// cafe list의 각 cafe에 sub 요청
void subCafeList(StompClient stompClient, List<String> cafeList,
    Map<String, List<UserModel>> allUsers) {
  for (final cafeId in cafeList) {
    stompClient.subscribe(
      destination: '/sub/cafe/$cafeId',
      callback: (frame) {
        // sub 응답 처리
        Map<String, dynamic> result = jsonDecode(frame.body!);

        // 카페에 사용자 add
        if (result["type"] == "add") {
          print("add user in cafe $cafeId");
          allUsers[cafeId]!
              .add(UserModel.fromJson(result["cafeUserProfileDto"]));
        }
        // 카페에서 사용자 delete
        else if (result["type"] == "delete") {
          print("delete user in cafe $cafeId");
          allUsers[cafeId]!
              .removeWhere((user) => user.loginId == result["loginId"]);
        }
      },
    );
  }
}

// cafe 업데이트(추가, 삭제) pub 요청
void pubCafe(
    StompClient stompClient, String type, String loginId, String cafeId) {
  stompClient.send(
    destination: '/pub/cafe/update',
    body: jsonEncode({
      "type": type,
      "loginId": loginId,
      "cafeId": cafeId,
    }),
  );
}

// cafe 업데이트 - user 추가
void addUserInCafe(StompClient stompClient, String loginId, String cafeId) {
  pubCafe(stompClient, "add", loginId, cafeId);
}

// cafe 업데이트 - user 삭제
void deleteUserInCafe(StompClient stompClient, String loginId, String cafeId) {
  pubCafe(stompClient, "delete", loginId, cafeId);
}
