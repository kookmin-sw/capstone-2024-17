import 'package:flutter/material.dart';
import 'package:frontend/notification.dart';
import 'package:frontend/widgets/top_appbar.dart';

final List<AlarmEvent> events = [];

class AlarmList extends StatefulWidget {
  const AlarmList({super.key});

  @override
  AlarmListWidgetState createState() => AlarmListWidgetState();
}

class AlarmEvent {
  final String messageTitle;
  final String messageBody;
  final DateTime time;
  final String type; // 이벤트 유형: accept, reject, send, offline

  AlarmEvent({
    required this.messageTitle,
    required this.messageBody,
    required this.time,
    required this.type,
  });
}

class AlarmListWidgetState extends State<AlarmList> {
  String? title;
  String? body;
  DateTime? datetime;

  @override
  void initState() {
    final fcm = FCM();
    fcm.setNotifications(); // 알림 설정

    fcm.messageStreamController.stream.listen((msg) {
      print('[alarmList content] $msg');
      setState(() {
        // 받은 알림을 맨 앞에 추가
        events.insert(
            0,
            AlarmEvent(
                messageTitle: msg['title'],
                messageBody: msg['body'],
                time: msg['sentTime'],
                type: 'accept'));
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: "알림 목록",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final time =
                    '${event.time.year}-${event.time.month.toString().padLeft(2, '0')}-${event.time.day.toString().padLeft(2, '0')} ${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}:${event.time.second.toString().padLeft(2, '0')}'; // 날짜와 시간을 문자열로 변환
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(
                            top: index == 0 ? 0.0 : 5.0, left: 5.0),
                        child: Text(event.messageBody),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
                        child: Text(
                          time,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const Divider(), //리스트 구분줄
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
