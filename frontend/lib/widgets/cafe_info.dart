import 'package:flutter/material.dart';

class CafeInfo extends StatelessWidget {
  final String address;
  final String cafeTelephone;
  final String businessHours;
  final String cafeOpen;
  final String cafeTakeout;
  final String cafeDelivery;
  final String cafeDineIn;

  const CafeInfo({
    super.key,
    required this.address,
    required this.cafeTelephone,
    required this.businessHours,
    required this.cafeOpen,
    required this.cafeTakeout,
    required this.cafeDelivery,
    required this.cafeDineIn,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 30,
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 300,
              child: Text(
                address,
                style: const TextStyle(fontSize: 20),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.phone,
              size: 25,
            ),
            const SizedBox(width: 20),
            Text(
              cafeTelephone,
              style: const TextStyle(
                fontSize: 20,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.schedule,
              size: 25,
            ),
            const SizedBox(width: 20),
            Text(
              businessHours,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }
}
