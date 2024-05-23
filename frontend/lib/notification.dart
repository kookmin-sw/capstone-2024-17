import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/matching_info_model.dart';
import 'package:frontend/widgets/dialog/notification_dialog.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// 백그라운드에서 수신된 메시지를 처리하기 위한 콜백 함수
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(); // 백그라운드일 때 firebase 초기화
  // file에 저장
  await saveMessageDataLogToFile(
      message.data['title'], message.data['body'], message.sentTime!);
}

// FCM 관련 기능을 관리하는 클래스
class FCM {
  final BuildContext context;
  final Function autoOffline;
  FCM(this.context, this.autoOffline);

  // 알림 설정
  setNotifications() {
    Permission.notification.request().then((status) => {
          if (status.isDenied)
            {print('사용자가 알림 권한을 거부했습니다.')}
          else if (status.isGranted)
            {print('사용자가 알림 권한을 허용했습니다.')}
        });

    FirebaseMessaging.onBackgroundMessage(
        onBackgroundMessage); // 백그라운드 메시지 처리 함수를 등록

    forgroundNotification();
    // backgroundNotification();
    // terminateNotification();
  }

  // 앱이 forground 상태일 경우를 위한 메소드
  forgroundNotification() {
    // onMessage: 메시지가 도착했을 때 발생하는 이벤트
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        // file에 저장
        await saveMessageDataLogToFile(
            message.data['title'], message.data['body'], message.sentTime!);

        // 이 부분은 작동하는지 테스트 후 수정
        print(message.data['title']);

        if (message.data['title'] == '커피챗 요청') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const ArriveRequestNotification();
            },
          );
        } else if (message.data['title'] == '커피챗 매칭 실패') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const ReqDeniedNotification();
            },
          );
        } else if (message.data['title'] == '커피챗 매칭 성공') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // 커피챗 진행중 여부 true로
              final MatchingInfoModel matchingInfo =
                  Provider.of<MatchingInfoModel>(context);
              matchingInfo.setIsMatching(true);

              return const ReqAcceptedNotification();
            },
          );

          // 오프라인으로 전환
          autoOffline();
        } else {
          // 오프라인 상태로 전환됨
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const OfflineNotification();
            },
          );
        }
      },
    );
  }

  // 앱이 background 상태일 경우를 위한 메소드: 앱을 열었을 때 수행할 로직이 없음!
  /*
  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {},
    );
  }
  */

  // 앱이 완전히 종료된 상태일 때 terminate하기 위한 메소드: 첫번째 메시지로 수행할 로직이 없음!
  /*
  terminateNotification() async {
    // fcm 메시지를 통해 앱이 열렸을 때, 그 첫번째 메시지를 가져옴
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
        */
}

// /data/user/0/com.example.frontend/app_flutter의 notification.txt에 저장함
Future<File> saveMessageDataLogToFile(
    String title, String body, DateTime sentTime) async {
  final directory = await getApplicationDocumentsDirectory();
  // print(directory.path);
  final file = File('${directory.path}/notification.txt');
  Map<String, String> log = {
    "title": title,
    "body": body,
    "sentTime": sentTime.toString(),
  };
  return file.writeAsString('\n${json.encode(log)}', mode: FileMode.append);
}

Future<void> updateNotificationLogFile(String userUUID) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notification.txt');
    if (await file.exists()) {
      final contents = await file.readAsLines(); // 파일의 모든 줄을 읽어옴
      if (contents.isNotEmpty) {
        final storedUUID = contents.first; // 파일의 첫 번째 줄에 저장된 UUID
        if (storedUUID != userUUID) {
          // 저장된 UUID와 주어진 UUID가 다를 경우: 파일 내용을 업데이트
          await file.writeAsString(userUUID); // 새로운 UUID가 첫 줄에 기록된 새 파일로 덮어씀
          print('UUID 다름: 파일 갱신됨');
        }
      } else {
        // 파일에 내용이 없는 경우
        await file.writeAsString(userUUID);
        print('UUID 없음: 기록됨');
      }
    } else {
      print('파일이 없는데요?');
    }
  } catch (e) {
    print('알림 기록 파일 업데이트 실패: $e');
  }
}

Future<String?> readNotificationLogFileContents() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notification.txt');
    if (await file.exists()) {
      final contents = await file.readAsString();
      return contents;
    } else {
      print('파일이 없는데요?');
      return '';
    }
  } catch (e) {
    print('알림기록 read 에러: $e');
    return '';
  }
}
