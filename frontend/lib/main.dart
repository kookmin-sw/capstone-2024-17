import 'package:frontend/screen/test_screen.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:frontend/service/stomp_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/screen/signup_screen.dart';
import 'package:frontend/screen/user_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:frontend/screen/cafe_details.dart';

// 웹소켓(stomp) 관련 변수
StompClient? stompClient;
const socketUrl = "http://43.203.218.27:8080/ws";

// 주변 카페에 있는 모든 유저 목록
Map<String, List<UserModel>>? allUsers;

const List<String> sampleCafeList = [
  "cafe-1",
  "cafe-2",
  "cafe-3",
  "cafe-4",
  "cafe-5",
];

void main() async {
  // http post 요청
  allUsers = await getAllUsers(sampleCafeList);

  // 웹소켓(stomp) 연결
  stompClient = StompClient(
    config: StompConfig.sockJS(
      url: socketUrl,
      onConnect: (_) {
        print("websocket connected !!");
        subCafeList(
            stompClient!, sampleCafeList, allUsers!); // 주변 모든 카페에 sub 요청
      },
      beforeConnect: () async {
        print('waiting to connect websocket...');
      },
      onWebSocketError: (dynamic error) => print(error.toString()),
    ),
  );
  stompClient!.activate();

  await dotenv.load();
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
    // 웹으로 실행하는 경우 필요한 키
    javaScriptAppKey: dotenv.env['JAVA_SCRIPT_APP_KEY'],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => allUsers,
        ),
        Provider(
          create: (_) => stompClient,
        ),
      ],
      child: MaterialApp(
        home: const Placeholder(), // 첫 화면으로 띄우고 싶은 스크린 넣기
        routes: <String, WidgetBuilder>{
          '/signup': (BuildContext context) => const SignupScreen(),
          '/signin': (BuildContext context) => const LoginScreen(),
          '/user': (BuildContext context) => const UserScreen(),
          '/cafe': (BuildContext context) => const CafeDetails(),
        },
      ),
    );
  }
}
