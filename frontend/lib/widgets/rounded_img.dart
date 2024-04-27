import 'package:flutter/material.dart';

class RoundedImg extends StatelessWidget {
  final Image image;
  final double size;

  const RoundedImg({
    super.key,
    required this.image,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: ClipOval(
        child: image,
      ),
    );
  }
}
