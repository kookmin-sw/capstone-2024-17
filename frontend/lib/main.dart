import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/firebase_options.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/service/stomp_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/screen/chatroom_list_screen.dart';
import 'package:frontend/screen/chat_screen.dart';
import 'package:frontend/screen/search_company_screen.dart';
import 'package:frontend/model/user_model.dart';
import 'package:frontend/model/my_cafe_model.dart';
import 'package:frontend/model/all_users_model.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userToken;
  late StompClient stompClient;
  int _selectedIndex = 0;
  late List<String> cafeList; // 주변 카페 리스트
  AllUsersModel allUsers = AllUsersModel({}); // 주변 카페에 있는 모든 유저 목록

  static late final List<Widget> _screenOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

  @override
  void initState() {
    super.initState();
    // 유저 토큰 가져오기
    storage.read(key: 'authToken').then((token) {
      userToken = token;

      // 웹소켓(stomp) 연결
      stompClient = StompClient(
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
      stompClient.activate();
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => stompClient,
        ),
        ChangeNotifierProvider(
          create: (context) => allUsers,
        ),
        ChangeNotifierProvider(
          create: (_) => MyCafeModel(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          splashColor: Colors.transparent, // 스플래시 효과 제거
          highlightColor: Colors.transparent, // 하이라이트 효과 제거
        ),
        initialRoute: '/', // 첫 화면으로 띄우고 싶은 스크린 넣기
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => (userToken == null)
              ? const LoginScreen()
              : Scaffold(
                  body: _screenOptions.elementAt(_selectedIndex),
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
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    unselectedItemColor: Colors.black,
                    selectedItemColor: const Color(0xffff6c3e),
                  ),
                ),
          '/signup': (BuildContext context) => const SignupScreen(),
          '/signin': (BuildContext context) => const LoginScreen(),
          '/user': (BuildContext context) => const UserScreen(),
          '/chatroomlist': (BuildContext context) => const ChatroomListScreen(),
          '/cafe': (BuildContext context) => const CafeDetails(),
          '/searchcompany': (BuildContext context) =>
              const SearchCompanyScreen(),
        },
      ),
    );
  }
}
