import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_config/flutter_config.dart';
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
      home: GoogleMapWidget(),
    );
  }
}

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  Set<Marker> _markers = {};
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _searchcafes(const LatLng(37.5925683, 127.0164784)); // 초기 위치에 대한 카페 검색
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) async {
    await _searchcafes(position.target); // 카메라 이동 시 카페 검색
  }

  Future<void> _searchcafes(LatLng position) async {

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=(cafe,카페,커피숍,커피 전문점)&location=${position.latitude},${position.longitude}&radius=1500&key=${dotenv.env['googleApiKey']}'));

    if (response.statusCode == 200) {
      print("성공");
      print("Response Body: ${response.body}");
      final data = json.decode(response.body);
      _setMarkers(data['results']);
    } else {
      print("실패");
      throw Exception('Failed to load pharmacies');
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.5925683, 127.0164784),
        zoom: 15,
      ),
      markers: _markers,
    );
  }
}