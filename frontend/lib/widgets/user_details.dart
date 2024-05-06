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
    required this.rating,
  });

  final String nickname;
  final String company;
  final String position;
  final String introduction;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        Thermometer(
          proportion: rating * 0.01,
        ),
        Container(
          width: 280,
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 10),
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
