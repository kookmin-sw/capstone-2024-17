import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/cafe_info.dart';
import 'package:frontend/widgets/user_item.dart';
import 'package:frontend/widgets/bottom_text_button.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/service/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:latlong2/latlong.dart' as latlong2;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CafeDetails(
          cafeId:"1", cafeName: "스타벅스 국민대점", cafeDetailsArguments: ['정보 없음'],), // 임시로 cafeId, cafeName 지정
    );
  }
}
const List<Map<String, dynamic>> sampleUserList = [
  {
    "nickname": "뽕순이",
    "companyName": "채연컴퍼니",
    "positionName": "집사",
    "introduction": "안녕하세요 뽕순이입니다 뽕",
  },
  {
    "nickname": "담",
    "companyName": "네카라쿠배당토",
    "positionName": "웹 프론트엔드",
    "introduction": "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ"
  },
  {
    "nickname": "잠온다",
    "companyName": "구글",
    "positionName": "데이터 엔지니어",
    "introduction": "잠오니까 요청하지 마세요. 감사합니다."
  },
  {
    "nickname": "내가제일잘나가",
    "companyName": "꿈의직장",
    "positionName": "풀스택",
    "introduction": "안녕하세요, 저는 제일 잘나갑니다. 잘 부탁드립니다. 요청 마니주세용 >3<"
  },
];

class CafeDetails extends StatefulWidget {

  final String cafeId;
  final String cafeName;
  final List<String> cafeDetailsArguments;

  const CafeDetails({
    super.key,
    required this.cafeId,
    required this.cafeName,
    required this.cafeDetailsArguments,
  });

  @override
  State<CafeDetails> createState() => _CafeDetailsState();
}

class _CafeDetailsState extends State<CafeDetails>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  final String ImageId = "";
  final places = GoogleMapsPlaces(apiKey: "${dotenv.env['googleApiKey']}");
  String photoUrl = '';

  void _startTimer() {
    print("타이머 시작");
    _timer = Timer.periodic(Duration(minutes: 20), (Timer timer) async {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      double cafeLat = double.parse(widget.cafeDetailsArguments[6]); // 카페 위도
      double cafeLong = double.parse(widget.cafeDetailsArguments[7]); // 카페 경도

      final latlong2.Distance distance = latlong2.Distance();
      final double meter = distance.as(
          latlong2.LengthUnit.Meter,
          latlong2.LatLng(position.latitude, position.longitude),
          latlong2.LatLng(cafeLat, cafeLong));

      if (meter > 500){
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
      PlacesDetailsResponse place = await places.getDetailsByPlaceId(widget.cafeDetailsArguments[9]);
      if (place.isOkay && place.result.photos.isNotEmpty) {
        String photoReference = place.result.photos[0].photoReference;
        photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${dotenv.env['googleApiKey']}';
        setState(() {});
      } else {
        throw Exception('No photo found for this place.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  TabController? tabController;
  List<UserModel> userList = [];

  void waitForUserList(String cafeId) async {
    userList = await getUserList(cafeId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPlacePhotoUri();
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      // 사용자 보기 탭 클릭 시, 서버에 해당 카페에 있는 유저 목록 get 요청
      if (tabController!.index == 1) {
        waitForUserList(widget.cafeId as String); //위도 경도로 사용자 요청?
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Text(
            widget.cafeName,
            style: const TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          backgroundColor: Colors.white,
          elevation: 1.0,
          shadowColor: Colors.black,
          leading: const Icon(Icons.arrow_back_ios),
          leadingWidth: 70,
        ),
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
                    itemCount: sampleUserList.length,
                    itemBuilder: (context, index) {
                      return userList.isEmpty
                          ? UserItem(
                              nickname: sampleUserList[index]["nickname"],
                              company: sampleUserList[index]["companyName"],
                              position: sampleUserList[index]["positionName"],
                              introduction: sampleUserList[index]
                                  ["introduction"],
                            )
                          : UserItem(
                              nickname: userList[index].nickname,
                              company: userList[index].companyName,
                              position: userList[index].positionName,
                              introduction: userList[index].introduction,
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
          BottomTextButton(
            text: "이 카페를 내 위치로 설정하기",
            handlePressed: () {
              _startTimer();
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}
