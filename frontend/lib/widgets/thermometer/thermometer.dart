import 'package:flutter/material.dart';

class Thermometer extends StatelessWidget {
  final double proportion;

  const Thermometer({
    super.key,
    required this.proportion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 280,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: FractionallySizedBox(
          widthFactor: proportion,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xffff916f),
            ),
          ),
        ),
      ),
    );
  }
}
