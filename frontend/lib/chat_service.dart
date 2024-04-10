// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatService {
  final StompClient stompClient;

  ChatService()
      : stompClient = StompClient(
            config: StompConfig.sockJS(
          url: 'http://localhost:8080/ws-chat',
          // url: 'http://${dotenv.env['MY_IP']}:8080/ws-chat',
          onConnect: onConnectCallback,
          onWebSocketError: (dynamic error) => print(error.toString()),
          onDisconnect: (_) => print('연결됨'),
        ));

  static void onConnectCallback(StompFrame frame) {
    print('연결해제됨');
  }

  void activateStompClient(Function() onActivated) {
    stompClient.activate();
    // activate가 끝나면 호출되는 콜백함수
    onActivated();
  }

  void disconnect() {
    stompClient.deactivate();
  }

  void subscribeToChatroom(String id, void Function(StompFrame) callback) {
    stompClient.subscribe(
        destination: '/sub/chatroom/$id',
        callback: (StompFrame frame) {
          callback(frame);
        });
  }

  // 메시지 전송: 채팅방 id, 스트링 message를 인자로
  void sendMessage(String id, String message) {
    stompClient.send(
      destination: '/pub/chatroom/$id',
      body: message,
    );
  }
}
