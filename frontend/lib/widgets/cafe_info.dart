import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

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
    bool isOpen = cafeOpen == 'true'; // 예를 선택하면 true, 그렇지 않으면 false
    bool isDineIn = cafeDineIn == 'true';
    bool isTakeout = cafeTakeout == 'true';

    return Column(

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 50),
            Icon(
              isDineIn ? Icons.fastfood_outlined : Icons.no_meals_sharp ,
              size: 20,
              color: isDineIn ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: Text(
                '매장 내 식사',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.clip,
              ),
            ),
            Icon(
              isTakeout ? Icons.wallet_giftcard_sharp : Icons.not_interested ,
              size: 20,
              color: isDineIn ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: Text(
                '테이크아웃',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
        SizedBox(height:10),
        Row(
          children: [
            // 이전 위젯들
            Container(
              width: 360, // 네모 박스의 가로 길이
              height: 1, // 네모 박스의 세로 길이
              color: Colors.grey , // 네모 박스의 색상
            ),
            // 이후에 추가할 위젯들
          ],
        ),
        SizedBox(height:15),
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
                style: const TextStyle(fontSize: 15),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
        SizedBox(height:15),
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
                fontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height:15),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.schedule,
              size: 25,
            ),
            const SizedBox(width: 20),
            Text(
              isOpen? '영업중':'영업종료',
              style: TextStyle(
                fontSize: 15,
                color: isOpen ? Colors.green : Colors.red, // cafeOpen이 true이면 초록색, 그렇지 않으면 검은색으로 설정
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(width: 25),
            const SizedBox(width: 20),
            Text(
              businessHours,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}
