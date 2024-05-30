import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/modal_button.dart';
import 'package:frontend/widgets/user/user_details.dart';

class UserDetailsModal extends StatelessWidget {
  const UserDetailsModal({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
    required this.handleChangeDialog,
    required this.rating,
    required this.userId,
  });

  final String nickname;
  final String company;
  final String position;
  final String introduction;
  final Function handleChangeDialog;
  final double rating;
  final int userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserDetails(
              nickname: nickname,
              company: company,
              position: position,
              introduction: introduction,
              rating: rating,
            ),
            ModalButton(
              text: "커피챗 요청하기",
              handlePressed: () => handleChangeDialog(userId),
            ),
          ],
        ),
      ),
    );
  }
}
