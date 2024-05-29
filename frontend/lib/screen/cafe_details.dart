import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/model/matching_info_model.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/service/stomp_service.dart';
import 'package:frontend/service/auto_offline_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/cafe_info.dart';
import 'package:frontend/widgets/bar/top_appbar.dart';
import 'package:frontend/widgets/user/user_item.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/dialog/yn_dialog.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/model/user_profile_model.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/model/all_users_model.dart';
import 'package:frontend/model/my_cafe_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:stomp_dart_client/stomp.dart';

const List<Map<String, dynamic>> sampleUserList = [
  {
    "nickname": "뽕순이",
    "company": "채연컴퍼니",
    "position": "집사",
    "introduction": "안녕하세요 뽕순이입니다 뽕",
    "rating": 10.0,
  },
  {
    "nickname": "담",
    "company": "네카라쿠배당토",
    "position": "웹 프론트엔드",
    "introduction": "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ",
    "rating": 20.0,
  },
  {
    "nickname": "잠온다",
    "company": "구글",
    "position": "데이터 엔지니어",
    "introduction": "잠오니까 요청하지 마세요. 감사합니다.",
    "rating": 30.0,
  },
  {
    "nickname": "내가제일잘나가",
    "company": "꿈의직장",
    "position": "풀스택",
    "introduction": "안녕하세요, 저는 제일 잘나갑니다. 잘 부탁드립니다. 요청 마니주세용 >3<",
    "rating": 40.0,
  },
];

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

  late AutoOfflineService autoOfflineService;
  late List<UserModel> userList;
  late MyCafeModel myCafe;
  late MatchingInfoModel matchingInfo;

  void _startTimer() {
    print("타이머 시작");
    _timer = Timer.periodic(const Duration(minutes: 5), (Timer timer) async {
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

  void _stopTimer() async {
    _timer?.cancel();

    // 오프라인으로 전환
    autoOfflineService.autoOffline();
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    autoOfflineService =
        Provider.of<AutoOfflineService>(context, listen: false);
    stompClient = Provider.of<StompClient>(context);
    userList = Provider.of<AllUsersModel>(context).getUserList(widget.cafeId);
    myCafe = Provider.of<MyCafeModel>(context);
    matchingInfo = Provider.of<MatchingInfoModel>(context);

    return Scaffold(
      appBar: TopAppBar(
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 240,
              child: Text(
                widget.cafeName,
                style: const TextStyle(
                    fontSize: 22, overflow: TextOverflow.ellipsis),
              ),
            ),
            (myCafe.cafeId != widget.cafeId)
                ? Container()
                : const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.circle,
                      size: 13,
                      color: Color(0xFFFF6C3E),
                    ),
                  ),
          ],
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
                    "assets/no_image.png",
                    width: 450,
                    height: 250,
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
                    address: widget.cafeDetailsArguments[0],
                    cafeOpen: widget.cafeDetailsArguments[1],
                    cafeTelephone: widget.cafeDetailsArguments[2],
                    cafeTakeout: widget.cafeDetailsArguments[3],
                    cafeDelivery: widget.cafeDetailsArguments[4],
                    cafeDineIn: widget.cafeDetailsArguments[5],
                    businessHours: widget.cafeDetailsArguments[8],
                  ),
                  Stack(
                    children: [
                      ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          return UserItem(
                            type: "cafeUser",
                            userId: userList[index].userId,
                            nickname: userList[index].nickname,
                            company: userList[index].company,
                            position: userList[index].position,
                            introduction: userList[index].introduction,
                            rating: userList[index].rating,
                            matchId: '', // 안 쓰는 값이기에 초기값 넣어줌
                            logoUrl: '',
                            requestTypeId: 0, // 안 쓰는 값이기에 초기값 넣어줌
                          );
                        },
                      ),
                      (myCafe.cafeId != null)
                          ? Container()
                          : ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          (myCafe.cafeId == widget.cafeId || matchingInfo.isMatching)
              ? Container()
              : BottomTextButton(
                  text: "이 카페를 내 위치로 지정하기",
                  handlePressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        bool setOrChange = myCafe.cafeId == null ? true : false;
                        String content = setOrChange
                            ? "${widget.cafeName}을(를) \n내 위치로 표시하시겠습니까?"
                            : "${widget.cafeName}을(를) 내 위치로 \n표시하도록 변경하시겠습니까?";

                        return YesOrNoDialog(
                          content: content,
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

                            try {
                              // 지정 카페 변경인 경우
                              if (!setOrChange) {
                                // 기존 카페에서 유저 삭제 pub 요청
                                deleteUserInCafe(
                                  stompClient,
                                  userId,
                                  myCafe.cafeId!,
                                );
                              }
                              // 카페에 유저 추가 pub 요청
                              addUserInCafe(
                                stompClient,
                                userId,
                                widget.cafeId,
                              );

                              // 이 카페에서 5분마다 반경 벗어남 체크
                              _startTimer();

                              myCafe.setMyCafe(
                                cafeId: widget.cafeId,
                                latitude: widget.cafeDetailsArguments[6],
                                longitude: widget.cafeDetailsArguments[7],
                              );
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => const OneButtonDialog(
                                  content: "카페 지정에 실패했습니다. \n잠시후 다시 시도해주세요.",
                                ),
                              );
                            }
                          },
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
