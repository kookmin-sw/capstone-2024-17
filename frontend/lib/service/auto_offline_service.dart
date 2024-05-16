import 'package:frontend/model/my_cafe_model.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/service/stomp_service.dart';
import 'package:stomp_dart_client/stomp.dart';

// 자동 오프라인 전환을 위한 서비스 클래스
class AutoOfflineService {
  StompClient stompClient;
  MyCafeModel myCafe;

  AutoOfflineService({required this.stompClient, required this.myCafe});

  // 자동 오프라인 전환 처리 함수
  void autoOffline() async {
    // 온라인 상태이면 오프라인으로 전환
    if (myCafe.cafeId != null) {
      int userId;
      Map<String, dynamic> res = await getUserDetail();

      if (res['success']) {
        userId = res['data']['userId'];
        print("!!!!유저 아이디: $userId");

        // pub 요청 - 카페 지정 해제
        deleteUserInCafe(
          stompClient,
          userId,
          myCafe.cafeId!,
        );
        myCafe.clearMyCafe();
      } else {
        print("!!!!유저 정보를 가져오는데 실패했습니다. ${res['message']}");
        return;
      }
    }
  }
}
