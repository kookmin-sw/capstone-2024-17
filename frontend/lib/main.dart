import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/screen/signup_screen.dart';
import 'package:frontend/screen/user_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/login_view_model.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:frontend/screen/cafe_details.dart';

Map<String, List<UserModel>>? allUsers;

const List<String> sampleCafeList = [
  "cafe-1",
  "cafe-2",
  "cafe-3",
  "cafe-4",
  "cafe-5",
];

void main() async {
  allUsers = await getAllUsers(sampleCafeList);

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
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(user: null),
        ), // provider로 감싸고 유저의 초기값 넣어주기
        Provider(
          create: (context) => allUsers,
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
