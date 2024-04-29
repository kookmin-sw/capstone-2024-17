import 'package:flutter/material.dart';

class BigThermometer extends StatelessWidget {
  final int temperature;

  const BigThermometer({
    super.key,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    String temperatureLabel = '';
    if (temperature == 100) {
      temperatureLabel = '타오르는 열정처럼';
    } else if (temperature >= 75 && temperature < 100) {
      temperatureLabel = '따스한 마음이 전해지는';
    } else if (temperature >= 50 && temperature < 75) {
      temperatureLabel = '따끈따끈~\n커피맛이 좋군요';
    } else if (temperature >= 25 && temperature < 50) {
      temperatureLabel = '가볍게 마시기 좋은';
    } else if (temperature > 0 && temperature < 25) {
      temperatureLabel = '입맛을 깨우는';
    } else {
      // 0도
      temperatureLabel = '남극인가?';
    }

    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [temperature / 100, 0.01],
            colors: [
              const Color(0xffff916f),
              Colors.grey[300]!,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Icon(
                Icons.coffee,
                size: 35,
              ),
              Text(
                temperatureLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  // color: Colors.white,
                ),
              ),
              Text(
                '$temperature℃',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]));
  }
}
