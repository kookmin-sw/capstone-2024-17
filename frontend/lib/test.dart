import 'package:flutter/material.dart';
import 'package:frontend/test/darthello.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const dartHello(); // 여기에 연결되는 스크린
  }
}
