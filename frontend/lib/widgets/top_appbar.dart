import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? buttons;
  @override
  final Size preferredSize;

  const TopAppBar({
    super.key,
    required this.title,
    this.buttons,
    this.preferredSize = const Size.fromHeight(70),
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
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
