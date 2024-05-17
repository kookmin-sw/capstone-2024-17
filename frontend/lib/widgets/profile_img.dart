import 'package:flutter/material.dart';

class ProfileImg extends StatelessWidget {
  final bool isLocal;
  final String logoUrl;

  const ProfileImg({
    super.key,
    required this.isLocal,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: (isLocal)
              ? Image.asset(
                  logoUrl,
                  fit: BoxFit.cover, // 이미지가 원 안에 꽉 차도록 합니다
                )
              : Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
