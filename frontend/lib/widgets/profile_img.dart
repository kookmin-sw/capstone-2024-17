import 'package:flutter/material.dart';

class ProfileImg extends StatelessWidget {
  final bool isLocal;
  final String logoUrl;
  final double size;

  const ProfileImg({
    super.key,
    required this.isLocal,
    required this.logoUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: CircleAvatar(
        radius: size / 2,
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

class ProfileImgMedium extends StatelessWidget {
  final bool isLocal;
  final String logoUrl;

  const ProfileImgMedium({
    super.key,
    required this.isLocal,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileImg(isLocal: isLocal, logoUrl: logoUrl, size: 100);
  }
}

class ProfileImgSmall extends StatelessWidget {
  final bool isLocal;
  final String logoUrl;

  const ProfileImgSmall({
    super.key,
    required this.isLocal,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileImg(isLocal: isLocal, logoUrl: logoUrl, size: 80);
  }
}

class ProfileImgXSmall extends StatelessWidget {
  final bool isLocal;
  final String logoUrl;

  const ProfileImgXSmall({
    super.key,
    required this.isLocal,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileImg(isLocal: isLocal, logoUrl: logoUrl, size: 50);
  }
}
