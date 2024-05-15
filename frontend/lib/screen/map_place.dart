import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/dialog/yn_dialog.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:frontend/service/stomp_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screen/alarm_list_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/model/all_users_model.dart';
import 'package:frontend/model/my_cafe_model.dart';
import 'package:frontend/model/map_request_dto.dart';
import 'cafe_details.dart';

class Google_Map extends StatefulWidget {
  final Function updateCafesCallback;
  const Google_Map({super.key, required this.updateCafesCallback});

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<Google_Map> {
  late MyCafeModel myCafe;
  late StompClient stompClient;
  late AllUsersModel allUsers;

  @override
  void initState() {
    super.initState();

    LocationPermission().then((_) {
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).then((position) {
        _getCurrentLocation();
      });
    });
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
  }

  @override
  void didChangeDependencies() {
    //변경 사항 파악
    super.didChangeDependencies();
    _mapLoad();
  }

  Future<void> _mapLoad() async {
    //현재 위치 기반으로 반경 원, 마커 다시 그림
    // getcurrentlocation으로 갈 시에 지도가 아닌 화면에서 camera position을 지정 => error.
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _setCircle(LatLng(position.latitude, position.longitude));
    _searchcafes(LatLng(position.latitude, position.longitude));
  }

  // 현재 위치로 이동
  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15.5,
    );
    setState(() {
      _myLocationEnabled = true;
    });
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    _setCircle(LatLng(position.latitude, position.longitude));
    _searchcafes(LatLng(position.latitude, position.longitude));
  }

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  Future<void> _searchcafes(LatLng position) async {
    final header = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": "${dotenv.env['googleApiKey']}",
      "Accept-Language": "ko",
      "X-Goog-FieldMask":
          "places.location,places.id,places.displayName,places.dineIn,places.takeout,places.formattedAddress,places.regularOpeningHours,places.internationalPhoneNumber,places.photos"
    };
    MapDTO map = MapDTO();
    List<String> inc = ["cafe"];

    int maxC = 0; //카페 개수 제한 //0으로 하면 그냥 다 나옴.. 사실상 최소 개수?
    double radius = 500;
    double lat = position.latitude;
    double log = position.longitude;
    Map<String, dynamic> body = map.request(inc, maxC, lat, log, radius);
    final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
        headers: header,
        body: json.encode(body));

    if (response.statusCode == 200) {
      // debugPrint("Response Body: ${response.body}"); // 주석 해제시 api 요청의 결과(response)를 볼 수 있음.
      final data = json.decode(response.body);
      _setMarkers(data['places'], position.latitude, position.longitude);
    } else {
      // print("실패");
      throw Exception('Failed to load cafe');
    }
  }

  // cafe 마커표시하고 누르면 cafe 이름보여줌
  void _setMarkers(List<dynamic> places, latitude, longitude) async {
    final Set<Marker> localMarkers = {};
    List<String> cafeList = [];

    // print("debug print");
    // print(places);

    for (var place in places) {
      cafeList.add(place['id']);

      // 여기서 라벨에 텍스트 명 변경가능
      final markerIcon = await _createMarkerImage(
        allUsers.getUserList(place['id']).length,
        place['id'],
      ); // 여기서 라벨에 텍스트 명 변경가능

      localMarkers.add(
        Marker(
          markerId: MarkerId(place['id']),
          position: LatLng(
            place['location']['latitude'],
            place['location']['longitude'],
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(
            title: place['displayName']['text'],
          ),
          onTap: () {
            String cafeLatitude = place['location']['latitude'] != null
                ? place['location']['latitude'].toString()
                : '정보 없음';
            String cafeLongitude = place['location']['longitude'] != null
                ? place['location']['longitude'].toString()
                : '정보 없음';

            String cafeName = place['displayName'] != null &&
                    place['displayName']['text'] != null
                ? place['displayName']['text']
                : '정보 없음';

            String cafeId = place['id'] ?? '정보 없음';

            String cafeAddress = place['formattedAddress'] ?? '정보 없음';

            String cafeOpen = place['regularOpeningHours'] != null &&
                    place['regularOpeningHours']['openNow'] != null
                ? place['regularOpeningHours']['openNow'].toString()
                : '정보 없음';

            String cafeTelephone = place['internationalPhoneNumber'] ?? '정보 없음';

            String cafeTakeout = place['takeout'] != null
                ? place['takeout'].toString()
                : '정보 없음';

            String cafeDelivery = place['delivery'] != null
                ? place['delivery'].toString()
                : '정보 없음';

            String cafeDineIn =
                place['dineIn'] != null ? place['dineIn'].toString() : '정보 없음';

            DateTime now = DateTime.now();
            int currentWeekday = (now.weekday) - 1;

            String businessHours = place['regularOpeningHours'] != null &&
                    place['regularOpeningHours']['weekdayDescriptions'] != null
                ? place['regularOpeningHours']['weekdayDescriptions']
                        [currentWeekday]
                    .toString()
                : '정보 없음';

            List<String> detailsArguments = [
              cafeAddress,
              cafeOpen,
              cafeTelephone,
              cafeTakeout,
              cafeDelivery,
              cafeDineIn,
              cafeLatitude,
              cafeLongitude,
              businessHours,
              cafeId,
            ];

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CafeDetails(
                      cafeId: cafeId,
                      cafeName: cafeName,
                      cafeDetailsArguments: detailsArguments)),
            );
          },
        ),
      );
    }
    setState(() {
      _markers = localMarkers;
    });

    widget.updateCafesCallback(cafeList);
  }

  // 반경 원 그리기
  void _setCircle(LatLng position) {
    Set<Circle> localcircles = {};

    localcircles = {
      Circle(
        circleId: const CircleId('currentCircle'),
        center: LatLng(position.latitude, position.longitude), // (위도, 경도)
        radius: 500, // 반경
        fillColor: Colors.deepOrange.shade100.withOpacity(0), // 채우기 색상
        strokeColor: (myCafe.cafeId != null)
            ? const Color(0xFFFF6C3E)
            : Colors.grey, // 테두리 색상
        strokeWidth: 3, // 테두리 두께
      )
    };
    setState(() {
      _circles = localcircles;
    });
  }

  // 마커 그리기 함수
  Future<Uint8List> _createMarkerImage(int numUsers, String cafeId) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0.0, 0.0),
            const Offset(160.0, 160.0))); // Canvas 크기를 100x100으로 변경

    // 마커 아이콘을 그리는 코드
    final paint = Paint();
    if (myCafe.cafeId == null) {
      paint.color = Colors.grey; // 오프라인 상태
    } else {
      if (myCafe.cafeId == cafeId) {
        paint.color = const Color(0xFFFF6C3E); // 온라인 - 내 카페
      } else {
        paint.color = const Color(0xFFFFAC7E); // 온라인 - 다른 카페
      }
    }
    canvas.drawCircle(const Offset(80, 80), 80, paint); // 중심(80, 80), 반지름 80

    // 텍스트 크기 계산 (중앙배치 하기 위함)
    const textStyle = TextStyle(color: Colors.white, fontSize: 50); // 폰트, 크기
    final textSpan = TextSpan(text: "$numUsers", style: textStyle); // 마진
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    // 텍스트 중앙 배치
    final textOffset = Offset(80 - textPainter.width / 2,
        80 - textPainter.height / 2); // 텍스트의 시작 위치 계산
    textPainter.paint(canvas, textOffset); // 텍스트 뿌림

    final picture = recorder.endRecording();
    final img = await picture.toImage(160, 160); // 이미지 크기 = 원의 크기
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    myCafe = Provider.of<MyCafeModel>(context);
    stompClient = Provider.of<StompClient>(context);
    allUsers = Provider.of<AllUsersModel>(context);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          GoogleMap(
            // mapType: MapType.terrain,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.611035490773, 126.99457310622), // 국민대

              zoom: 15,
            ),
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
                LocationPermission().then((_) {
                  Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  ).then((position) {
                    _searchcafes(LatLng(position.latitude, position.longitude));
                  });
                });
              },
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 버튼 모서리 둥글기
              ),
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            top: 80,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AlarmList()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange, // 배경 색상 설정
                shape: const CircleBorder(), // 원 모양의 버튼을 만들기 위해 사용
                padding: const EdgeInsets.all(10), // 버튼의 패딩 설정
              ),
              child: const Icon(Icons.add_alert,
                  color: Colors.white70), // 아이콘과 색상 설정
            ),
          ),
          (myCafe.cafeId == null)
              ? Container()
              : Positioned(
                  width: 140,
                  bottom: 100,
                  left: (screenSize.width / 2) - 70,
                  child: ElevatedButton(
                    onPressed: () {
                      print('위치 공유 끄기 버튼 클릭 !!');

                      showDialog(
                        context: context,
                        builder: (context) {
                          return YesOrNoDialog(
                            content: "위치 공유를 끄겠습니까?",
                            firstButton: "확인",
                            secondButton: "취소",
                            handleFirstClick: () async {
                              int userId;
                              Map<String, dynamic> res = await getUserDetail();
                              if (res['success']) {
                                userId = res['data']['userId'];
                                print("!!!!유저 아이디: $userId");
                              } else {
                                print(
                                    "!!!!유저 정보를 가져오는데 실패했습니다. ${res['message']}");
                                return;
                              }
                              deleteUserInCafe(
                                  stompClient, userId, myCafe.cafeId!);
                              myCafe.clearMyCafe();
                            },
                            handleSecondClick: () {},
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // 배경 색상 설정
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)), //테두리 둥글기 설정
                    ),
                    child: const Text(
                      "위치 공유 OFF",
                      style: TextStyle(color: Colors.white), // 폰트 색상 설정
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
