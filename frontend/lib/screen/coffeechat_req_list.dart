import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screen/alarm_list_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/alert_dialog_yesno_widget.dart';
import 'package:frontend/widgets/button/bottom_text_button.dart';
import 'package:frontend/widgets/color_text_container.dart';
import 'package:frontend/widgets/top_appbar.dart';
import 'package:frontend/widgets/user_details.dart';
import 'package:frontend/widgets/user_item.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

const List<Map<String, dynamic>> sampleUserList = [
  {
    "nickname": "뽕순이",
    "companyName": "채연컴퍼니",
    "positionName": "집사",
    "introduction": "안녕하세요 뽕순이입니다 뽕",
    "rating": 10.0,
  },
  {
    "nickname": "담",
    "companyName": "네카라쿠배당토",
    "positionName": "웹 프론트엔드",
    "introduction": "안녕하세욯ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ",
    "rating": 20.0,
  },
  {
    "nickname": "잠온다",
    "companyName": "구글",
    "positionName": "데이터 엔지니어",
    "introduction": "잠오니까 요청하지 마세요. 감사합니다.",
    "rating": 30.0,
  },
  {
    "nickname": "내가제일잘나가",
    "companyName": "꿈의직장",
    "positionName": "풀스택",
    "introduction": "안녕하세요, 저는 제일 잘나갑니다. 잘 부탁드립니다. 요청 마니주세용 >3<",
    "rating": 40.0,
  },
];
bool timerend = false;

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
                SentReq(
                  matchId: matchId,
                  nickname: receiverNickname,
                  company: receiverCompany,
                  position: receiverPosition,
                  introduction: receiverIntroduction,
                  rating: receiverRating,
                  question: Question,
                ),
                ReceivedReq(), // 이 부분은 나중에 수정 필요
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class SentReq extends StatefulWidget {
  final String? matchId;
  final String nickname;
  final String company;
  final String position;
  final String introduction;
  final double rating;
  final String question;

  const SentReq({
    Key? key,
    this.matchId,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
    required this.rating,
    required this.question,
  }) : super(key: key);

  @override
  _SentReqState createState() => _SentReqState();
}

class _SentReqState extends State<SentReq> {
  late int _endTime;

  @override
  void initState() {
    super.initState();
    timerend = false;
    _endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 10; // 10분후
  }

  Future<void> handleRequestCancel() async {
    try {
      Map<String, dynamic> response = await matchCancelRequest(widget.matchId!);

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

  void showAlertDialogWithContext(BuildContext context) {
    showAlertDialog(
        context, "제한 시간이 완료되었습니다.\n다시 매칭 요청을 진행해주세요.", handleRequestCancel);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
          width: 370,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: UserDetails(
            nickname: widget.nickname,
            company: widget.company,
            position: widget.position,
            introduction: widget.introduction,
            rating: widget.rating,
          ),
        ),
        ColorTextContainer(text: "# ${widget.question}"),
        Expanded(child: SizedBox(height: 10)),
        CountdownTimer(
          endTime: _endTime,
          onEnd: () {
            // 카운트다운 타이머가 끝났을 때
            if (!timerend) {
              showAlertDialogWithContext(context);
            }
          },
          widgetBuilder: (_, CurrentRemainingTime? time) {
            if (time == null) {
              return Text('남은 시간: 00:00');
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
            if (widget.matchId != null) {
              showAlertDialogYesNo(
                  context, "매칭 취소", "매칭을 종료하시겠습니까?", handleRequestCancel);
              timerend = true;
            }
          },
        ),
      ],
    );
  }
}

class ReceivedReq extends StatelessWidget {
  const ReceivedReq({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: sampleUserList.length,
        itemBuilder: (context, index) {
          return UserItem(
            type: "receivedReqUser",
            userId: sampleUserList[index]["userId"], //변경필요
            nickname: sampleUserList[index]["nickname"],
            company: sampleUserList[index]["companyName"],
            position: sampleUserList[index]["positionName"],
            introduction: sampleUserList[index]["introduction"],
            rating: sampleUserList[index]["rating"],
          );
        },
      ),
    );
  }
}
