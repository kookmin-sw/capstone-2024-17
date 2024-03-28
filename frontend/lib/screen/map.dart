import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: mapScreen(),
  ),
  );
}
class mapScreen extends StatefulWidget {
  @override
  _mapScreenState createState() => _mapScreenState();
}

class _mapScreenState extends State<mapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    _markers.addAll(
      _foodies.map(
            (e) => Marker(
          markerId: MarkerId(e['name'] as String),
          infoWindow: InfoWindow(title: e['name'] as String),
          position: LatLng(
            e['latitude'] as double,
            e['longitude'] as double,
          ),
        ),
      ),
    );
    super.initState();
  }

  final _markers = <Marker>{};
  final _foodies = [
    {
      "name": "카페아일랜드",
      "latitude": 37.5925414,
      "longitude": 127.0170871,
    },
    {
      "name": "카페핸드",
      "latitude":  37.593260320178935,
      "longitude": 127.01515591535698,
    },
    {
      "name": "펠어커피",
      "latitude":  37.59324683702535,
      "longitude": 127.01490680535643,
    },
    {
      "name": "멜랑슈 에스프레소",
      "latitude": 37.593311913011235,
      "longitude": 127.01674115525596,
    },
    {
      "name": "투썸플레이스",
      "latitude": 37.59354169227075,
      "longitude": 127.01655437554344,
    },
  ];

  CameraPosition _currentPosition = CameraPosition(
    // target: LatLng(37.611108, 126.997340), //사용자 지정 좌표 (학교)
    target: LatLng(37.5925683,127.0164784), //성신여대 입구
    zoom: 18, //확대
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: _currentPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete();
          },
          markers: _markers,
        ),
      ),
    );
  }
}
