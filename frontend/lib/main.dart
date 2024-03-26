import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/login_view_model.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  await dotenv.load();
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
    // 웹으로 실행하는 경우 필요한 키
    javaScriptAppKey: dotenv.env['JAVA_SCRIPT_APP_KEY'],
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
