import 'package:flutter/material.dart';

void main() {
  runApp(dartHello());
}

class dartHello extends StatelessWidget {
  const dartHello({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('앱제목')),
          body: Text('안녕'),
          bottomNavigationBar: BottomAppBar(child: Text('하단바임 ㅅㄱ')),
        ));
  }
}