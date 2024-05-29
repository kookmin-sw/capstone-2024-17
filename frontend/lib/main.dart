import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/model/matching_info_model.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/notification.dart';
import 'package:frontend/screen/edit_profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/auto_offline_service.dart';
import 'package:frontend/service/stomp_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/screen/chatroom_list_screen.dart';
import 'package:frontend/screen/search_company_screen.dart';
import 'package:frontend/model/user_profile_model.dart';
import 'package:frontend/model/my_cafe_model.dart';
import 'package:frontend/model/all_users_model.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/screen/map_place.dart';
import 'package:frontend/screen/signup_screen.dart';
import 'package:frontend/screen/user_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:frontend/screen/cafe_details.dart';

// 유저 토큰 저장하는 스토리지
const storage = FlutterSecureStorage();

// 웹소켓(stomp) URL
const socketUrl = "http://3.36.108.21:8080/ws";

void main() async {
  // firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
    // 웹으로 실행하는 경우 필요한 키
    javaScriptAppKey: dotenv.env['JAVA_SCRIPT_APP_KEY'],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  MyCafeModel myCafe = MyCafeModel();

  final stompclient = StompClient(
    config: StompConfig.sockJS(
      url: socketUrl,
      onConnect: (_) {
        print("websocket connected !!");
      },
      beforeConnect: () async {
        print('waiting to connect websocket...');
      },
      onWebSocketError: (dynamic error) => print(error.toString()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider(create: (_) => stompclient),
          Provider(
            create: (_) => AutoOfflineService(
              stompClient: stompclient,
              myCafe: myCafe,
            ),
          ),
          ChangeNotifierProvider(create: (_) => MatchingInfoModel()),
          ChangeNotifierProvider(create: (_) => UserProfileModel()),
          ChangeNotifierProvider(create: (_) => AllUsersModel({})),
          ChangeNotifierProvider(create: (_) => myCafe),
          ChangeNotifierProvider(create: (_) => SelectedIndexModel()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            splashColor: Colors.transparent, // 스플래시 효과 제거
            highlightColor: Colors.transparent, // 하이라이트 효과 제거
          ),
          initialRoute: '/',
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => const MyHomePage(),
            '/signup': (BuildContext context) => const SignupScreen(),
            '/signin': (BuildContext context) => const LoginScreen(),
            '/user': (BuildContext context) => const UserScreen(),
            '/chatroomlist': (BuildContext context) =>
                const ChatroomListScreen(),
            '/cafe': (BuildContext context) => const CafeDetails(),
            '/searchcompany': (BuildContext context) =>
                const SearchCompanyScreen(),
            '/coffeechatreqlist': (BuildContext context) =>
                const CoffeechatReqList(
                  matchId: '',
                  Question: '',
                  receiverCompany: '',
                  receiverPosition: '',
                  receiverIntroduction: '',
                  receiverRating: 0.0,
                  receiverNickname: '',
                ),
            '/editprofile': (BuildContext context) => const EditProfileScreen(),
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userToken;
  late StompClient stompClient;

  late UserProfileModel userProfile;
  late List<String> cafeList; // 주변 카페 리스트
  late AllUsersModel allUsers;
  late MatchingInfoModel matchingInfo; // 커피챗 진행중 정보

  late final List<Widget> _screenOptions;

  void updateCafeList(List<String> cafeList) {
    setState(() {
      this.cafeList = cafeList;
    });

    // 로그인된 상태이면 - 유저 목록 post, sub 요청
    if (userToken != null) {
      // http post 요청
      getAllUsers(userToken!, cafeList).then((value) {
        allUsers.setAllUsers(value);

        // 주변 모든 카페에 sub 요청
        subCafeList(stompClient, cafeList, allUsers);
      });
    }
  }

  // 알림 권한 요청
  void _permissionWithNotification() async {
    await [Permission.notification].request();
  }

  @override
  void initState() {
    super.initState();
    _permissionWithNotification();

    stompClient = Provider.of<StompClient>(context, listen: false);
    userProfile = Provider.of<UserProfileModel>(context, listen: false);
    allUsers = Provider.of<AllUsersModel>(context, listen: false);

    // 유저 토큰 가져오기
    storage.read(key: 'authToken').then((token) {
      setState(() {
        userToken = token;
      });

      // 웹소켓 연결
      stompClient.activate();

      // 유저 정보 가져오기
      getUserDetail().then((userDetail) {
        print('[main userDetail] $userDetail');
        userProfile.setProfile(
          userId: userDetail['data']['userId'],
          nickname: userDetail['data']['nickname'],
          logoUrl: (userDetail['data']['company'] != null)
              ? userDetail['data']['company']['logoUrl']
              : '',
          company: (userDetail['data']['company'] != null)
              ? userDetail['data']['company']['name']
              : '미인증',
          position: userDetail['data']['position'],
          introduction: userDetail['data']['introduction'] ?? '',
          rating: userDetail['data']['coffeeBean'],
        );

        // 커피챗 진행중 여부 가져오기
        getMatchingInfo(userProfile.userId).then((value) {
          matchingInfo.setIsMatching(value["isMatching"]);
          // 커피챗 진행중이면 상대방 정보도 가져오기
          if (value["isMatching"]) {
            matchingInfo.setMatching(
              matchId: value["matchId"],
              myId: value["myId"],
              myNickname: value["myNickname"],
              myCompany: value["myCompany"],
              partnerId: value["partnerId"],
              partnerCompany: value["partnerCompany"],
              partnerNickname: value["partnerNickname"],
            );
          }
          print("~~~~~성공~~~~isMatching: ${matchingInfo.isMatching}");
        });
      });

      // 알림 설정
      final fcm = FCM(
        context,
        Provider.of<AutoOfflineService>(context, listen: false).autoOffline,
      );
      fcm.setNotifications();
      // 알림 로그를 저장할 파일 생성
      getApplicationDocumentsDirectory().then((dir) {
        File('${dir.path}/notification.txt');
      });

      // 화면 리스트 초기화
      _screenOptions = [
        Google_Map(updateCafesCallback: updateCafeList),
        const CoffeechatReqList(
          matchId: '',
          Question: '',
          receiverCompany: '',
          receiverPosition: '',
          receiverIntroduction: '',
          receiverRating: 0.0,
          receiverNickname: '',
        ),
        const ChatroomListScreen(),
        const UserScreen(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    matchingInfo = Provider.of<MatchingInfoModel>(context);

    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    final selectedIndex = selectedIndexProvider.selectedIndex;
    return (userToken == null)
        ? const LoginScreen()
        : Scaffold(
            body: _screenOptions.elementAt(selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              iconSize: 26,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.map_outlined,
                  ),
                  label: '지도',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.coffee_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.coffee_rounded,
                  ),
                  label: '커피챗',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.forum_outlined,
                  ),
                  label: '채팅',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outlined,
                  ),
                  label: 'MY',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndexProvider.selectedIndex = index;
                if (index == 1) {
                  selectedIndexProvider.selectedTabIndex = 0; // 보낸 요청 탭으로
                  // 커피챗 매칭정보 가져오기
                  getUserDetail().then((userDetail) {
                    getMatchingInfo(userDetail["data"]["userId"]).then((value) {
                      // 커피챗 진행중 여부 저장
                      matchingInfo.setIsMatching(value["isMatching"]);

                      // 커피챗 진행중이면 상대방 정보도 저장
                      if (value["isMatching"]) {
                        matchingInfo.setMatching(
                          matchId: value["matchId"],
                          myId: value["myId"],
                          myNickname: value["myNickname"],
                          myCompany: value["myCompany"],
                          partnerId: value["partnerId"],
                          partnerCompany: value["partnerCompany"],
                          partnerNickname: value["partnerNickname"],
                        );
                      }
                    });
                  });
                }
              },
              showSelectedLabels: false,
              showUnselectedLabels: false,
              unselectedItemColor: Colors.black,
              selectedItemColor: const Color(0xffff6c3e),
            ),
          );
  }
}
