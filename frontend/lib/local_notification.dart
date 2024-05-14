import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 알림 컨트롤러 초기화
Future<void> localNotification_init() async {
  // 안드로이드 초기화 세팅: 알림 아이콘 설정
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // ios 초기화 세팅: 보류

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    // iOS: iosInitializationSettings,
  );

  // 알림 클릭 시 경로 설정도 여기서 가능한듯?
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

Future showLocalNotification(message) async {
  String title = '';
  String body = '';

  if (Platform.isAndroid) {
    title = message.data['title'];
    body = message.data['body'];
  }
  /*
  if(Platform.isIOS){
    // (안드로이드 / ios 에 따라 message 오는 구조가 다르다)
  }
  */

  // AOS, iOS 별로 notification 표시 설정
  var androidNotiDetails = AndroidNotificationDetails(title, body,
      importance: Importance.max, priority: Priority.max);
  // var iOSNotiDetails = IOSNotificationDetails();

  var details = NotificationDetails(android: androidNotiDetails);

  await flutterLocalNotificationsPlugin.show(0, title, body, details);
  // 0은 notification id
}
