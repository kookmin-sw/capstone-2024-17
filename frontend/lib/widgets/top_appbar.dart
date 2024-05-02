import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? buttons;
  @override
  final Size preferredSize;

  const TopAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.buttons,
    this.preferredSize = const Size.fromHeight(70),
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        title: (titleWidget != null)
            ? titleWidget
            : Text(
                title!,
                style: const TextStyle(fontSize: 24),
              ),
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        leading: Navigator.of(context).canPop() // 스택에 더 페이지가 있는지 확인
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop(); // 현재 페이지에서 뒤로 가기
                },
              )
            : null,
        leadingWidth: 70,
        elevation: 1.0,
        shadowColor: Colors.black,
        actions: buttons,
      ),
    );
  }
}

class TopAppBarWithButton extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? buttons;
  @override
  final Size preferredSize = const Size.fromHeight(70);

  const TopAppBarWithButton({super.key, required this.title, this.buttons});

  @override
  Widget build(BuildContext context) {
    return TopAppBar(
      title: title,
      buttons: buttons,
    );
  }
}

class ChatroomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String nickname;
  final Image logoImage;
  @override
  final Size preferredSize = const Size.fromHeight(70);

  const ChatroomAppBar({
    super.key,
    required this.nickname,
    required this.logoImage,
  });

  @override
  Widget build(BuildContext context) {
    return TopAppBar(
      titleWidget: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: logoImage.image,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.mode_standby,
                    color: Colors.lightGreen,
                    size: 15,
                  ),
                  Text(' 온라인', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
