import 'package:flutter/material.dart';
import 'package:frontend/model/matching_info_model.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/screen/chat_screen.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/service/auto_offline_service.dart';
import 'package:frontend/widgets/user_details_modal.dart';
import 'package:frontend/widgets/choose_purpose.dart';
import 'package:frontend/widgets/user_details.dart';
import 'package:frontend/widgets/color_text_container.dart';
import 'package:frontend/widgets/button/bottom_two_buttons.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:provider/provider.dart';

class UserItem extends StatelessWidget {
  final String type;
  final int userId;
  final String nickname;
  final String company;
  final String position;
  final String introduction;
  final double rating;
  final String matchId;
  final String logoUrl;
  final int requestTypeId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject; // onReject 함수 추가

  const UserItem({
    super.key,
    required this.type,
    required this.userId,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
    required this.rating,
    required this.matchId,
    required this.logoUrl,
    required this.requestTypeId,
    this.onAccept,
    this.onReject, // onReject 매개변수 설정
  }); // key 매개변수 설정

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            if (type == "cafeUser") {
              return ReqDialog(
                nickname: nickname,
                company: company,
                position: position,
                introduction: introduction,
                rating: rating,
                userId: userId,
              );
            } else if (type == "receivedReqUser") {
              return ReceivedReqDialog(
                  nickname: nickname,
                  company: company,
                  position: position,
                  introduction: introduction,
                  rating: rating, // 여기에서 rating을 전달합니다.
                  receiverId: userId, //여기선 요청 받은 애의 userId를 씀
                  matchId: matchId,
                  logoUrl: logoUrl,
                  requestTypeId: requestTypeId,
                  onAccept: onAccept,
                  onReject: onReject);
            } else {
              return Container();
            }
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            (company == '무소속')
                ? const ProfileImgSmall(
                    isLocal: true,
                    logoUrl: "assets/coffee_bean.png",
                  )
                : ProfileImgSmall(
                    isLocal: true,
                    logoUrl: "assets/$company-logo.png",
                  ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nickname,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    "$company / $position",
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    introduction,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 보낸 요청 상세보기 모달
class ReqDialog extends StatefulWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;
  final double rating;
  final int userId;

  const ReqDialog({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
    required this.rating,
    required this.userId,
  });

  @override
  State<ReqDialog> createState() => _ReqDialogState();
}

int receiverId = 0;

class _ReqDialogState extends State<ReqDialog> {
  bool isNext = false;
  int receiverId = 0; // receiverId를 state로 추가

  handleChangeDialog(int userId) {
    setState(() {
      isNext = !isNext;
      receiverId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: isNext
          ? ChoosePurpose(
              userId: receiverId,
            ) // receiverId를 ChoosePurpose 위젯에 전달
          : UserDetailsModal(
              nickname: widget.nickname,
              company: widget.company,
              position: widget.position,
              introduction: widget.introduction,
              rating: widget.rating,
              userId: widget.userId,
              handleChangeDialog: handleChangeDialog,
            ),
    );
  }
}

List<String> purpose = [
  "당신의 회사가 궁금해요",
  "당신의 업무가 궁금해요",
  "같이 개발 이야기 나눠요",
  "점심시간 함께 산책해요"
];

// 받은 요청 상세보기 모달
class ReceivedReqDialog extends StatelessWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;
  final double rating;
  final int receiverId;
  final String matchId;
  final String logoUrl;
  final int requestTypeId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject; // onReject 함수 추가

  const ReceivedReqDialog({
    super.key, // Key 매개변수 추가
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
    required this.rating,
    required this.receiverId,
    required this.matchId,
    required this.logoUrl,
    required this.requestTypeId,
    required this.onAccept,
    required this.onReject,
  }); // Key 매개변수 설정

  @override
  Widget build(BuildContext context) {
    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    final autoOfflineService =
        Provider.of<AutoOfflineService>(context, listen: false);
    final matchingInfo = Provider.of<MatchingInfoModel>(context);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserDetails(
              nickname: nickname,
              company: company,
              position: position,
              introduction: introduction,
              rating: rating,
            ),
            ColorTextContainer(text: "# ${purpose[requestTypeId]}"),
            BottomTwoButtons(
              first: "수락",
              second: "거절",
              handleFirstClick: () async {
                // 수락 버튼을 누를 때 호출할 함수
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      matchId: matchId,
                      nickname: nickname,
                      logoUrl: logoUrl,
                      chatroomId: null,
                    ),
                  ),
                );
                // 오프라인으로 전환
                autoOfflineService.autoOffline();
              },
              handleSecondClick: () async {
                onReject?.call(); // onReject 함수 호출
              },
            ),
          ],
        ),
      ),
    );
  }
}
