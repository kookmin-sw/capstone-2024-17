import 'dart:convert';

import 'package:frontend/model/all_users_model.dart';
import 'package:frontend/model/user_model.dart';
import 'package:stomp_dart_client/stomp.dart';

// cafe list의 각 cafe에 sub 요청
void subCafeList(
    StompClient stompClient, List<String> cafeList, AllUsersModel allUsers) {
  if (!stompClient.connected) {
    print("stompClient is not connected !!");
    return;
  }

  for (final cafeId in cafeList) {
    stompClient.subscribe(
      destination: '/sub/cafe/$cafeId',
      callback: (frame) {
        // sub 응답 처리
        Map<String, dynamic> result = jsonDecode(frame.body!);

        // 카페에 사용자 add
        if (result["type"] == "add") {
          print("add user in cafe $cafeId");
          allUsers.addUser(cafeId, UserModel.fromJson(result["cafeUserDto"]));
        }
        // 카페에서 사용자 delete
        else if (result["type"] == "delete") {
          print("delete user in cafe $cafeId");
          allUsers.deleteUser(cafeId, result["userId"]);
        }
      },
    );
  }
}

// cafe 업데이트(추가, 삭제) pub 요청
void pubCafe(
    StompClient stompClient, String type, String userId, String cafeId) {
  if (!stompClient.connected) {
    print("stompClient is not connected !!");
    return;
  }

  stompClient.send(
    destination: '/pub/cafe/update',
    body: jsonEncode({
      "type": type,
      "userId": userId,
      "cafeId": cafeId,
    }),
  );
}

// cafe 업데이트 - user 추가
void addUserInCafe(StompClient stompClient, String userId, String cafeId) {
  pubCafe(stompClient, "add", userId, cafeId);
}

// cafe 업데이트 - user 삭제
void deleteUserInCafe(StompClient stompClient, String userId, String cafeId) {
  pubCafe(stompClient, "delete", userId, cafeId);
}
