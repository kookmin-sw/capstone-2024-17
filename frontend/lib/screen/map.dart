import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
      home: map_widget(),
    );
  }
}

class map_widget extends StatefulWidget {
  const map_widget({Key? key, required}) : super(key: key);

  @override
  State<map_widget> createState() => _map_widgetState();
}

class _map_widgetState extends State<map_widget> {
  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  late GoogleMapController _controller;
  bool _myLocationEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      print('사용자가 위치 권한을 거부했습니다.');
    } else if (status.isGranted) {
      print('사용자가 위치 권한을 허용했습니다.');
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18,
    );
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {
      _myLocationEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> places = [
      {
        "name": "카페아일랜드",
        "latitude": 37.5925414,
        "longitude": 127.0170871,
      },
      {
        "name": "카페핸드",
        "latitude": 37.593260320178935,
        "longitude": 127.01515591535698,
      },
      {
        "name": "펠어커피",
        "latitude": 37.59324683702535,
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
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.5925683, 127.0164784), //성신여대 입구
              zoom: 18,
            ),
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: false,
            markers: Set<Marker>.of(places.map((place) {
              return Marker(
                markerId: MarkerId(place['name']),
                position: LatLng(place['latitude'], place['longitude']),
                infoWindow: InfoWindow(title: place['name']),
                onTap: () { //마커 클릭 시 이동하는 곳
                  Navigator.push( 
                      context,
                      CupertinoPageRoute(
                          builder: (context) => MarkerDetailScreen()));
                },
              );
            })),
            onMapCreated: (controller) => _controller = controller,
          ),
          Positioned(
            bottom: 25,
            left: 16,
            child: FloatingActionButton( //현재 위치 표시하는 버튼
              onPressed: _getCurrentLocation, //현재 위치 구하는 함수로 이동
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              elevation: 8, // 그림자 크기
              child: Icon(Icons.my_location),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 현재 버튼 모서리 둥글기
              ),
            ),
          ),
          Positioned(
            top: 54,
            child: CupertinoButton(
              onPressed: () {
                Navigator.push( //상단바의 위치검색 클릭 시 이동
                    context,
                    CupertinoPageRoute(
                        builder: (context) => MarkerDetailScreen()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 21,
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        '위치 검색',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 13.0),
                    ),
                  ],
                ),
                decoration: BoxDecoration( // 위치 검색 버튼 꾸미는 곳
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkerDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marker Detail'),
      ),
      body: Center(
        child: Text('Marker detail screen'),
      ),
    );
  }
}

// class marker_widget extends StatelessWidget {
//   const marker_widget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
