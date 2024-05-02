import 'package:flutter/material.dart';
import 'package:frontend/widgets/top_appbar.dart';

final List<AlarmEvent> events = [
  AlarmEvent(
    message: "00님이 커피챗 요청을 수락했습니다.",
    time: DateTime.now(),
    type: "accept",
  ),
  AlarmEvent(
    message: "00님이 커피챗 요청을 거절했습니다.",
    time: DateTime.now(),
    type: "reject",
  ),
  AlarmEvent(
    message: "00님이 커피챗 요청을 보냈습니다.",
    time: DateTime.now(),
    type: "send",
  ),
  AlarmEvent(
    message: "오프라인으로 전환되었습니다.",
    time: DateTime.now(),
    type: "offline",
  ),
];

class AlarmList extends StatefulWidget {
  const AlarmList({super.key});

  @override
  AlarmListWidgetState createState() => AlarmListWidgetState();
}

class AlarmEvent {
  final String message;
  final DateTime time;
  final String type; // 이벤트 유형: accept, reject, send, offline

  AlarmEvent({
    required this.message,
    required this.time,
    required this.type,
  });
}

class AlarmListWidgetState extends State<AlarmList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                          child: Text(event.message),
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
      ),
    );
  }
}
