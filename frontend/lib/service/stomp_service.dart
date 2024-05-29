import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/model/all_users_model.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:stomp_dart_client/stomp.dart';

// cafe list의 각 cafe에 sub 요청
void subCafeList({
  required StompClient stompClient,
  required List<String> cafeList,
  required AllUsersModel allUsers,
  required int userId,
}) {
  if (!stompClient.connected) {
    throw Exception("stompClient is not connected !!");
  }

  for (final cafeId in cafeList) {
    stompClient.subscribe(
      destination: '/sub/cafe/$cafeId',
      callback: (frame) {
        // sub 응답 처리
        Map<String, dynamic> result = jsonDecode(frame.body!);

        // 자기 자신에 대한 sub은 무시
        if (result["userId"] == userId) {
          return;
        }

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
void pubCafe(StompClient stompClient, String type, int userId, String cafeId) {
  if (!stompClient.connected) {
    throw Exception("stompClient is not connected !!");
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
void addUserInCafe(StompClient stompClient, int userId, String cafeId) {
  pubCafe(stompClient, "add", userId, cafeId);
}

// cafe 업데이트 - user 삭제
void deleteUserInCafe(StompClient stompClient, int userId, String cafeId) {
  pubCafe(stompClient, "delete", userId, cafeId);
}
