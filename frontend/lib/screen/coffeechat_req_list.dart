import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screen/alarm_list_screen.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/alert_dialog_yesno_widget.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/color_text_container.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:frontend/widgets/user_details.dart';
import 'package:frontend/widgets/user_item.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

bool timerend = false;
List<String> purpose = [
  "당신의 회사가 궁금해요",
  "당신의 업무가 궁금해요",
  "같이 개발 이야기 나눠요",
  "점심시간 함께 산책해요"
];
void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CoffeechatReqList(
        matchId: '',
        receiverNickname: '',
        receiverCompany: '',
        receiverPosition: '',
        receiverIntroduction: '',
        receiverRating: 0.0,
        Question: '',
      ),
    );
  }
}

class CoffeechatReqList extends StatelessWidget {
  final String matchId;
  final String receiverNickname;
  final String receiverCompany;
  final String receiverPosition;
  final String receiverIntroduction;
  final double receiverRating;
  final String Question;

  const CoffeechatReqList({
    Key? key,
    required this.matchId,
    required this.receiverNickname,
    required this.receiverCompany,
    required this.receiverPosition,
    required this.receiverIntroduction,
    required this.receiverRating,
    required this.Question,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TopAppBar(
          title: "커피챗 요청 목록",
        ),
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: '보낸 요청'),
                Tab(text: '받은 요청'),
              ],
              indicatorColor: Color(0xff212121),
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            Expanded(
              child: TabBarView(children: [
                SentReq(),
                ReceivedReq(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class SentReq extends StatefulWidget {
  @override
  _SentReqState createState() => _SentReqState();
}

class _SentReqState extends State<SentReq> {
  late Future<Map<String, dynamic>> _sendinfoFuture;
  bool timerend = false;

  @override
  void initState() {
    super.initState();
    timerend = false;
    _sendinfoFuture = sendinfo();
  }

  Future<void> handleRequestCancel() async {
    try {
      Map<String, dynamic> response = await matchCancelRequest("matchId");

      if (response['success'] == true) {
        print("정상적으로 삭제됨");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlarmList()),
        );
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> sendinfo() async {
    try {
      // 로그인 한 유저의 senderId 가져오기
      Map<String, dynamic> res = await getUserDetail();
      if (res['success']) {
        int senderId = res['data']['userId'];
        Map<String, dynamic> response = await requestInfoRequest(senderId);
        return response;
      } else {
        print(
            '로그인된 유저 정보를 가져올 수 없습니다: ${res["message"]}(${res["statusCode"]})');
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _sendinfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data == null ||
            snapshot.data!['success'] != true ||
            snapshot.hasError) {
          return Center(
            child: Text(
              '보낸 요청이 없습니다 :(',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        } else {
          var data = snapshot.data!['data'];
          int requestTypeId = data['requestTypeId'] is int
              ? data['requestTypeId']
              : int.tryParse(data['requestTypeId'].toString()) ?? 0;
          // var matchId = data['matchId']; // 아직 백엔드에 없음
          DateTime _endTime = DateTime.fromMillisecondsSinceEpoch(
              int.parse(data['expirationTime']));

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                width: 370,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: UserDetails(
                  nickname: data['receiverInfo']['nickname'] ?? 'nickname',
                  company: data['receiverInfo']['company']['name'] ?? 'company',
                  position: data['receiverInfo']['position'] ?? 'position',
                  introduction:
                      data['receiverInfo']['introduction'] ?? 'introduction',
                  rating:
                      (data['receiverInfo']['coffeeBean'] ?? 0.0).toDouble(),
                ),
              ),
              ColorTextContainer(text: "# ${purpose[requestTypeId]}"),
              Expanded(child: SizedBox(height: 10)),
              CountdownTimer(
                endTime: _endTime.millisecondsSinceEpoch,
                onEnd: () {
                  if (!timerend) {
                    showAlertDialog(
                        context, "제한 시간이 완료되었습니다.\n다시 매칭 요청을 진행해주세요.");
                    setState(() {
                      _sendinfoFuture = sendinfo();
                    });
                  }
                },
                widgetBuilder: (_, CurrentRemainingTime? time) {
                  if (time == null) {
                    return Text('남은 시간: 00:00',
                        style: TextStyle(fontSize: 20, color: Colors.black));
                  }
                  int minutes = time.min ?? 0;
                  int seconds = time.sec ?? 0;
                  return Text(
                    '남은 시간: ${minutes.toString().padLeft(2, '0')}분 ${seconds.toString().padLeft(2, '0')}초',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  );
                },
              ),
              SizedBox(height: 10),
              BottomTextButton(
                text: "요청 취소하기",
                handlePressed: () async {
                  showAlertDialogYesNo(
                      context, "매칭 취소", "매칭을 종료하시겠습니까?", handleRequestCancel);
                  timerend = true;
                },
              ),
            ],
          );
        }
      },
    );
  }
}

class ReceivedReq extends StatefulWidget {
  @override
  _ReceivedReqState createState() => _ReceivedReqState();
}

class _ReceivedReqState extends State<ReceivedReq> {
  List<Map<String, dynamic>> revList = [];

  @override
  void initState() {
    super.initState();
    fetchReceiveList();
  }

  Future<void> fetchReceiveList() async {
    int userId = 0;

    try {
      Map<String, dynamic> res = await getUserDetail();
      if (res['success']) {
        userId = res['data']['userId'];
      } else {
        print(
            'Unable to fetch user details: ${res["message"]}(${res["statusCode"]})');
        return;
      }

      try {
        List<Map<String, dynamic>> resultList =
            await receivedInfoRequest(userId);
        setState(() {
          revList = resultList;
        });
      } catch (e) {
        setState(() {
          revList = [];
        });
      }
    } catch (e) {
      print('Error 2: $e');
    }
  }

  Future<void> handleMatchAccept(String matchId) async {
    await matchAcceptRequest(matchId);
  }

  Future<void> handleMatchDecline(String matchId) async {
    await matchDeclineRequest(matchId);
    fetchReceiveList(); // Refresh data after rejection
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: revList.isEmpty
          ? Center(
              child: Text(
                '받은 요청이 없습니다 :(',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: revList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> senderData = revList[index]['senderInfo'];

                // 수락 버튼을 누를 때 호출할 함수
                void handleAccept() {
                  handleMatchAccept(revList[index]["matchId"]);
                }

                void handleReject() {
                  handleMatchDecline(revList[index]["matchId"]);
                }

                return UserItem(
                  type: "receivedReqUser",
                  userId: senderData["userId"] ?? 1,
                  nickname: senderData["nickname"] ?? "Unknown",
                  company: senderData["company"]?["name"] ?? "Unknown",
                  position: senderData["position"] ?? "Unknown",
                  introduction: senderData["introduction"] ?? "No introduction",
                  rating: senderData["rating"] != null
                      ? double.parse(senderData["rating"])
                      : 0.0,
                  matchId: revList[index]["matchId"],
                  requestTypeId: int.parse(revList[index]["requestTypeId"]),
                  onAccept: handleAccept,
                  onReject: handleReject,
                );
              },
            ),
    );
  }
}
