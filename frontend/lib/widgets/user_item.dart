import 'package:flutter/material.dart';
import 'package:frontend/widgets/user_details_modal.dart';
import 'package:frontend/widgets/choose_purpose.dart';

class UserItem extends StatelessWidget {
  final String nickname;
  final String company;
  final String position;
  final String introduction;

  const UserItem({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 클릭 시 유저 상세보기 모달 띄우기
        showDialog(
          context: context,
          builder: (context) {
            return ReqDialog(
              nickname: nickname,
              company: company,
              position: position,
              introduction: introduction,
            );
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
