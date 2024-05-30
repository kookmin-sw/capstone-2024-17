import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:frontend/widgets/thermometer/thermometer.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            (company == '무소속')
                ? const ProfileImgMedium(
                    isLocal: true,
                    logoUrl: "assets/coffee_bean.png",
                  )
                : ProfileImgMedium(
                    isLocal: true,
                    logoUrl: "assets/$company-logo.png",
                  ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              // Expanded 추가
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity, // Column의 최대 너비를 사용
                    child: Text(
                      nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      company,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      position,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
          height: 100, // 높이를 제한하고 있음
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
              maxLines: 5, // 최대 라인 수를 설정하여 오버플로우 방지
              overflow: TextOverflow.ellipsis, // 오버플로우가 발생할 경우 줄임처리
            ),
          ),
        ),
      ],
    );
  }
}
