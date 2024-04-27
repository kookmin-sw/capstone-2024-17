import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_text_button.dart';

class EditProfileScreen extends StatefulWidget {
  final String nickname;
  final String logoInfo;
  final String companyName;
  final String position;
  final int temperature;
  final String introduction;
  
  const EditProfileScreen({
    super.key, 
    required this.nickname,
    required this.logoInfo,
    required this.companyName,
    required this.position,
    required this.temperature,
    required this.introduction,
  });

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '프로필 수정',
            style: TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              Column(children: [
                Text('nickname: ${widget.nickname}'),
                Text('logoInfo: ${widget.logoInfo}'),
                Text('companyName: ${widget.companyName}'),
                Text('position: ${widget.position}'),
                Text('temperature: ${widget.temperature}'),
                Text('introduction: ${widget.introduction}'),
                BottomTextButton(
                      text: '저장하기',
                      handlePressed: () {
                      },
                    ),
              ],)
          ],
        )),
  );
  }
}
