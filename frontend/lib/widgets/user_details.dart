import 'package:flutter/material.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:frontend/widgets/thermometer.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  final String nickname;
  final String company;
  final String position;
  final String introduction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 35,
            ),
            const ProfileImg(logo: "assets/coffee_bean.png"),
            const SizedBox(
              width: 35,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  company,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  position,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Thermometer(
          proportion: 0.7,
        ),
        Container(
          width: 280,
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Text(
              introduction,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
