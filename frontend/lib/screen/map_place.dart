import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  // const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<Google_Map> {


  @override
  void initState() {
    super.initState();
    requestLocationPermission(); // 위치 권한 여부
    _searchcafes(const LatLng(37.5925683, 127.0164784)); // 초기 위치에 대한 카페 검색

  }

  late GoogleMapController _controller;
  bool _myLocationEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  // 위치 권한 부여
  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      print('사용자가 위치 권한을 거부했습니다.');
    } else if (status.isGranted) {
      print('사용자가 위치 권한을 허용했습니다.');
    }
  }

  // 현재 위치로 이동

  Future<void> _getCurrentLocation() async {
    print("현재 위치로 이동");
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _searchcafes(LatLng(position.latitude, position.longitude));

    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
    // print("포지션 설졍 완료");
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // print("카메라 이동 완료");
    setState(() {
      _myLocationEnabled = true;
    });
  }

  Set<Marker> _markers = {};

  void _onCameraMove(CameraPosition position) async {
    await _searchcafes(position.target); // 카메라 이동 시 카페 검색
  }

  Future<void> _searchcafes(LatLng position) async {
    // try{
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=(coffee||카페||커피숍||커피 전문점||cafe)&location=${position.latitude},${position.longitude}&radius=1500&key=${dotenv.env['googleApiKey']}'));

      if (response.statusCode == 200) {
        print("성공");
        print("Response Body: ${response.body}");
        final data = json.decode(response.body);
        _setMarkers(data['results']);

    } else {
        print("실패");
        throw Exception('Failed to load cafe');
      }

  }

  // cafe 마커표시하고 누르면 cafe 이름보여줌
  void _setMarkers(List<dynamic> places) {
    final Set<Marker> localMarkers = {};
    for (var place in places) {
      localMarkers.add(Marker(
        markerId: MarkerId(place['place_id']),
        position: LatLng(place['geometry']['location']['lat'],
            place['geometry']['location']['lng']),
        infoWindow: InfoWindow(title: place['name']),
      ));
    }

    setState(() {
      _markers = localMarkers;
    });
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
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: false,
            markers: _markers,
            circles: Set.from([Circle( circleId: CircleId('currentCircle'),
              center: LatLng(37.5925683, 127.0164784), //원의 중심 위치
              radius: 500, //미터 단위 반경
              fillColor: Colors.deepOrange.shade100.withOpacity(0.5), //숫자가 높아질수록 색상 진해짐
              strokeColor:  Colors.deepOrange.shade100.withOpacity(0.1), //테두리
            ),],),
            onMapCreated: (controller) => _controller = controller,
          ),
          Positioned(
            bottom: 25,
            left: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
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
