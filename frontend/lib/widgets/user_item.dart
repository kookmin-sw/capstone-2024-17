import 'package:flutter/material.dart';
import 'package:frontend/widgets/user_details_modal.dart';
import 'package:frontend/widgets/choose_purpose.dart';
import 'package:frontend/widgets/user_details.dart';
import 'package:frontend/widgets/color_text_container.dart';
import 'package:frontend/widgets/button/bottom_two_buttons.dart';

class UserItem extends StatelessWidget {
  final String type;
  final String nickname;
  final String company;
  final String position;
  final String introduction;

  const UserItem({
    super.key,
    required this.type,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 클릭 시 유저 상세보기 or 받은요청 상세보기 모달 띄우기
        showDialog(
          context: context,
          builder: (context) {
            if (type == "cafeUser") {
              return ReqDialog(
                nickname: nickname,
                company: company,
                position: position,
                introduction: introduction,
              );
            } else if (type == "receivedReqUser") {
              return ReceivedReqDialog(
                nickname: nickname,
                company: company,
                position: position,
                introduction: introduction,
              );
            } else {
              return Container();
            }
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: 400,
        height: 100,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            const SizedBox(
              width: 100,
              child: Icon(
                Icons.circle_notifications,
                size: 70,
              ),
            ),
            // CircleAvatar(child: Image.asset("assets/logo.png"),),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nickname),
                Text("$company / $position"),
                SizedBox(
                  width: 200,
                  child: Text(
                    introduction,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ReqDialog extends StatefulWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;

  const ReqDialog({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  @override
  State<ReqDialog> createState() => _ReqDialogState();
}

class _ReqDialogState extends State<ReqDialog> {
  bool isNext = false;

  handleChangeDialog() {
    setState(() {
      isNext = !isNext;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: isNext
          ? const ChoosePurpose()
          : UserDetailsModal(
              nickname: widget.nickname,
              company: widget.company,
              position: widget.position,
              introduction: widget.introduction,
              handleChangeDialog: handleChangeDialog,
            ),
    );
  }
}

// 받은 요청 상세보기 모달
class ReceivedReqDialog extends StatelessWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;

  const ReceivedReqDialog({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
        width: 350,
        height: 470,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            UserDetails(
              nickname: nickname,
              company: company,
              position: position,
              introduction: introduction,
            ),
            const ColorTextContainer(text: "# 당신의 업무가 궁금해요."),
            const Expanded(child: SizedBox()),
            const BottomTwoButtons(
              first: "수락",
              second: "거절",
            ),
          ],
        ),
      ),
    );
  }
}
