import 'package:flutter/material.dart';

class CafeInfo extends StatelessWidget {
  final String location;
  final String phoneNumber;
  final String businessHours;

  const CafeInfo({
    super.key,
    required this.location,
    required this.phoneNumber,
    required this.businessHours,
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
                location,
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
              phoneNumber,
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
