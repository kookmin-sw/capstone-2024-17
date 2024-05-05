import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 백그라운드에서 수신된 메시지를 처리하기 위한 콜백 함수
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(); // firebase 초기화

  // 알림을 notification으로 처리(어디에 쓰는거지)
  if (message.data.containsKey('notification')) {
    final notification = message.data['notification'];
  }
}

// FCM 관련 기능을 관리하는 클래스
class FCM {
  // StreamController 생성: 어느 타이밍에 데이터가 들어올 지 모를 때 비동기로 작업을 처리
  final dataStreamController = StreamController<String>.broadcast();
  final titleStreamController = StreamController<String>.broadcast();
  final bodyStreamController = StreamController<String>.broadcast();

  // 알림 설정
  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(
        onBackgroundMessage); // 백그라운드 메시지 처리 함수를 등록

    forgroundNotification();
    backgroundNotification();
    terminateNotification();
  }

  // 앱이 forground 상태일 경우를 위한 메소드
  forgroundNotification() {
    // onMessage: 메시지가 도착했을 때 발생하는 이벤트
    FirebaseMessaging.onMessage.listen(
      (message) async {
        // (메시지에는 notification 메시지, data 메시지가 있다)
        if (message.data.containsKey('notification')) {
          print('[notification forground]${message.data['notification']}');
          dataStreamController.sink.add(message.data['notification']);
        }
        titleStreamController.sink.add(message.notification!.title!);
        bodyStreamController.sink.add(message.notification!.body!);
      },
    );
  }

  // 앱이 background 상태일 경우를 위한 메소드
  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        if (message.data.containsKey('notification')) {
          print('[notification background]${message.data['notification']}');
          dataStreamController.sink.add(message.data['notification']);
        }
        titleStreamController.sink.add(message.notification!.title!);
        bodyStreamController.sink.add(message.notification!.body!);
      },
    );
  }

  // 앱이 완전히 종료된 상태일 때 terminate하기 위한 메소드
  terminateNotification() async {
    // fcm 메시지를 통해 앱이 열렸을 때, 그 첫번째 메시지를 가져옴
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      if (initialMessage.data.containsKey('notification')) {
        print('[notification terminate]${initialMessage.data['notification']}');
        dataStreamController.sink.add(initialMessage.data['notification']);
      }
      titleStreamController.sink.add(initialMessage.notification!.title!);
      bodyStreamController.sink.add(initialMessage.notification!.body!);
    }
  }

  dispose() {
    dataStreamController.close();
    bodyStreamController.close();
    titleStreamController.close();
  }
}
