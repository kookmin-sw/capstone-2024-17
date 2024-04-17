import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await Geolocator.checkPermission();
  if (status == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: Google_Map(),
    );
  }
}

class Google_Map extends StatefulWidget {
  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<Google_Map> {

  @override
  void initState() {
    super.initState();
    LocationPermission(); // 위치 권한 여부
  }

  late GoogleMapController _controller;
  bool _myLocationEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // 위치 권한 부여
  Future<void> LocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      print('사용자가 위치 권한을 거부했습니다.');
    } else if (status.isGranted) {
      print('사용자가 위치 권한을 허용했습니다.');
    }
  }

  // 지도가 생성된 후에 호출되는 콜백
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _getCurrentLocation(); // 지도가 생성된 후에 현재 위치로 이동하고 카페 검색
  }

  // 현재 위치로 이동
  Future<void> _getCurrentLocation() async {
    print("현재 위치로 이동");
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
    setState(() {
      _myLocationEnabled = true;
    });
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    _searchcafes(LatLng(position.latitude, position.longitude));
    _setCircle(LatLng(position.latitude, position.longitude));
  }

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};


  Future<void> _searchcafes(LatLng position) async {
    // try{
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=(카페||커피숍||커피 전문점||cafe||coffee)'
              '&location=${position.latitude},${position.longitude}'
              '&radius=500'
              '&key=${dotenv.env['googleApiKey']}'));

      if (response.statusCode == 200) {
        print("Response Body: ${response.body}");
        final data = json.decode(response.body);
        _setMarkers(data['results'],position.latitude,position.longitude);
    } else {
        print("실패");
        throw Exception('Failed to load cafe');
      }
  }

  // cafe 마커표시하고 누르면 cafe 이름보여줌
  void _setMarkers(List<dynamic> places,latitude,longitude) async {
    final Set<Marker> localMarkers = {};
    for (var place in places) {

      // 여기서 라벨에 텍스트 명 변경가능
      final markerIcon = await _createMarkerImage(place['name']); // 여기서 라벨에 텍스트 명 변경가능

      var place_lat = place['geometry']['location']['lat'];
      var place_lng = place['geometry']['location']['lng'];
      final latlong2.Distance distance = latlong2.Distance(); //이름 지정 안 하면 geo머시기랑 충돌남
      final double meter = distance.as(latlong2.LengthUnit.Meter,latlong2.LatLng(latitude, longitude), latlong2.LatLng(place_lat, place_lng));
      print("두 좌표간 거리 = $meter");
      // print("lat=${place_lat}, lng${place_lng}");
      // print(calculateDistance(, ));

      if(meter <= 500){
        localMarkers.add(Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(
            place['geometry']['location']['lat'],
            place['geometry']['location']['lng'],
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon), // 라벨을 포함한 마커 아이콘 설정
          infoWindow: InfoWindow(
            title: place['name'],
          ),
        ));
      }
    }

    setState(() {
      _markers = localMarkers;
    });
  }

  // 반경 원 그리기
  void _setCircle(LatLng position){
    Set<Circle> localcircles = {};

    localcircles = Set.from([Circle(
    circleId: CircleId('currentCircle'),
    center: LatLng(position.latitude, position.longitude), // (위도, 경도)
    radius: 500, // 반경
    fillColor: Colors.deepOrange.shade100.withOpacity(0.5), // 채우기 색상
    strokeColor: Colors.deepOrange.shade100.withOpacity(0.1), // 테두리 색상

    )]);
    setState(() {
      _circles = localcircles;
    });
  }


  // 마커 그리기 함수
  Future<Uint8List> _createMarkerImage(String label) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(160.0, 160.0))); // Canvas 크기를 100x100으로 변경

    // 마커 아이콘을 그리는 코드
    final paint = Paint()..color = Color.fromRGBO(246, 82, 16, 1); //red, green, blue, opacity
    canvas.drawCircle(Offset(80, 80), 80, paint); // 중심(80, 80), 반지름 80

    // 텍스트 크기 계산 (중앙배치 하기 위함)
    final textStyle = TextStyle(color: Colors.white, fontSize: 30); // 폰트, 크기
    final textSpan = TextSpan(text: label, style: textStyle); // 마진
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    // 텍스트 중앙 배치
    final textOffset = Offset(80 - textPainter.width / 2, 80 - textPainter.height / 2); // 텍스트의 시작 위치 계산
    textPainter.paint(canvas, textOffset); // 텍스트 뿌림

    final picture = recorder.endRecording();
    final img = await picture.toImage(160, 160); // 이미지 크기 = 원의 크기
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.5925683, 127.0164784), // 성신여대 입구
              zoom: 15,
            ),
            // onCameraMove: _onCameraMove,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: false,
            markers: _markers,
            circles: _circles,
            onMapCreated: _onMapCreated, // 지도가 생성된 후에 호출되는 콜백
          ),
          Positioned(
            bottom: 25,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                _getCurrentLocation();
              },
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              elevation: 8,
              child: Icon(Icons.my_location),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 버튼 모서리 둥글기
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class MarkerDetailScreen extends StatefulWidget {
//   @override
//   _MarkerDetailScreenState createState() => _MarkerDetailScreenState();
// }
//
// class _MarkerDetailScreenState extends State<MarkerDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Marker Detail'),
//       ),
//       body: Center(
//         child: Text('Marker detail screen'),
//       ),
//     );
//   }
// }
