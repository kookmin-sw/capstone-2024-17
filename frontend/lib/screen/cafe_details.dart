import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/service/stomp_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/cafe_info.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:frontend/widgets/user_item.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/dialog/yn_dialog.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/model/my_cafe_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:stomp_dart_client/stomp.dart';

class CafeDetails extends StatefulWidget {
  final String cafeId;
  final String cafeName;
  final List<String> cafeDetailsArguments;

  const CafeDetails({
    super.key,
    this.cafeId = "defaultCafeId",
    this.cafeName = "defaultCafeName",
    this.cafeDetailsArguments = const [],
  });

  @override
  State<CafeDetails> createState() => _CafeDetailsState();
}

class _CafeDetailsState extends State<CafeDetails>
    with SingleTickerProviderStateMixin {
  late StompClient stompClient;
  TabController? tabController;
  Timer? _timer;

  final String ImageId = "";
  final places = GoogleMapsPlaces(apiKey: "${dotenv.env['googleApiKey']}");
  String photoUrl = '';
  List<UserModel>? userList;
  late MyCafeModel myCafe;

  void _startTimer() {
    print("타이머 시작");
    _timer = Timer.periodic(const Duration(minutes: 20), (Timer timer) async {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double cafeLat = double.parse(widget.cafeDetailsArguments[6]); // 카페 위도
      double cafeLong = double.parse(widget.cafeDetailsArguments[7]); // 카페 경도

      const latlong2.Distance distance = latlong2.Distance();
      final double meter = distance.as(
          latlong2.LengthUnit.Meter,
          latlong2.LatLng(position.latitude, position.longitude),
          latlong2.LatLng(cafeLat, cafeLong));

      if (meter > 500) {
        _stopTimer();
        print("어플의 지원 범위인 500m를 벗어났습니다.");
      }
      print("두 좌표간 거리 = $meter");
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> getPlacePhotoUri() async {
    try {
      PlacesDetailsResponse place =
          await places.getDetailsByPlaceId(widget.cafeDetailsArguments[9]);
      if (place.isOkay && place.result.photos.isNotEmpty) {
        String photoReference = place.result.photos[0].photoReference;
        photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${dotenv.env['googleApiKey']}';
        setState(() {});
      } else {
        throw Exception('No photo found for this place.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPlacePhotoUri();
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      // 사용자 보기 탭 클릭 시
      if (tabController!.index == 1) {
        // 사용자 목록 업데이트 ?
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    stompClient = Provider.of<StompClient>(context);
    userList =
        Provider.of<Map<String, List<UserModel>>>(context)[widget.cafeId];
    myCafe = Provider.of<MyCafeModel>(context);

    return Scaffold(
      appBar: TopAppBar(
        title: widget.cafeName,
      ),
      body: Column(
        children: [
          Center(
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: 450,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/cafe.jpeg",
                    width: 450,
                    fit: BoxFit.fitWidth,
                  ),
          ),
          TabBar(
            controller: tabController,
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            indicatorWeight: 4,
            tabs: const [
              Tab(text: "카페 상세정보"),
              Tab(text: "사용자 보기"),
            ],
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TabBarView(
                controller: tabController,
                children: [
                  CafeInfo(
                    // List<String> detailsArguments = [
                    //   cafeAddress, 0
                    //   cafeOpen, 1
                    //   cafeTelephone, 2
                    //   cafeTakeout, 3
                    //   cafeDelivery, 4
                    //   cafeDineIn, 5
                    //   cafeLatitude, 6
                    //   cafeLongitude, 7
                    //   openingHours, 8
                    //   cafeid, 9
                    //   photourl, 10
                    // ];
                    address: widget.cafeDetailsArguments[0],
                    cafeOpen: widget.cafeDetailsArguments[1],
                    cafeTelephone: widget.cafeDetailsArguments[2],
                    cafeTakeout: widget.cafeDetailsArguments[3],
                    cafeDelivery: widget.cafeDetailsArguments[4],
                    cafeDineIn: widget.cafeDetailsArguments[5],
                    businessHours: widget.cafeDetailsArguments[8],
                  ),
                  ListView.builder(
                    itemCount: userList!.length,
                    itemBuilder: (context, index) {
                      return UserItem(
                        type: "cafeUser",
                        nickname: userList![index].nickname,
                        company: userList![index].companyName,
                        position: userList![index].positionName,
                        introduction: userList![index].introduction,
                        rating: 0.0,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          (myCafe.cafeId == widget.cafeId)
              ? Container()
              : BottomTextButton(
                  text: "이 카페를 내 위치로 지정하기",
                  handlePressed: () {
                    _startTimer();

                    showDialog(
                      context: context,
                      builder: (context) {
                        bool setOrChange = myCafe.cafeId == null ? true : false;
                        String content = setOrChange
                            ? "${widget.cafeName}을(를) 내 위치로 표시하겠습니까?"
                            : "${widget.cafeName}을(를) 내 위치로 표시하도록 변경하겠습니까?";

                        return YesOrNoDialog(
                          content: content,
                          firstButton: "확인",
                          secondButton: "취소",
                          handleFirstClick: () {
                            _stopTimer();

                            // 지정 카페 변경인 경우
                            if (!setOrChange) {
                              // 기존 카페에서 유저 삭제 pub 요청
                              deleteUserInCafe(
                                stompClient,
                                "test",
                                myCafe.cafeId!,
                              );
                            }
                            // 카페에 유저 추가 pub 요청
                            addUserInCafe(
                              stompClient,
                              "test",
                              widget.cafeId,
                            );

                            myCafe.setMyCafe(
                              cafeId: widget.cafeId,
                              latitude: widget.cafeDetailsArguments[6],
                              longitude: widget.cafeDetailsArguments[7],
                            );
                          },
                          handleSecondClick: _stopTimer,
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
