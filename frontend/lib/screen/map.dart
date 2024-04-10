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
      home: MapWidget(),
    );
  }
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {

  @override
  void initState() {
    super.initState();
    requestLocationPermission(); //위치 권한 여부
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
            mapType: MapType.terrain,
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
                onTap: () {
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
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              elevation: 8,
              child: Icon(Icons.my_location),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkerDetailScreen extends StatefulWidget {
  @override
  _MarkerDetailScreenState createState() => _MarkerDetailScreenState();
}

class _MarkerDetailScreenState extends State<MarkerDetailScreen> {
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
