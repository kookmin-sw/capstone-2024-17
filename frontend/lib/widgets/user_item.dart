import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;

  const UserItem({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      width: 400,
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Icon(
              Icons.circle_notifications,
              size: 70,
            ),
          ),
          // CircleAvatar(child: Image.asset("assets/logo.png"),),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nickname),
              Text("$company / $position"),
              SizedBox(
                width: 200,
                child: Text(
                  introduction,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
