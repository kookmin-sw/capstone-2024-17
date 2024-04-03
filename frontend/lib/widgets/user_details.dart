import 'package:flutter/material.dart';
import 'package:frontend/widgets/profile_img.dart';
import 'package:frontend/widgets/choose_purpose.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({
    super.key,
    required this.nickname,
    required this.company,
    required this.position,
    required this.introduction,
  });

  final String nickname;
  final String company;
  final String position;
  final String introduction;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 350,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 25,
                  ),
                  const ProfileImg(logo: "assets/coffee_bean.png"),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        company,
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        position,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      introduction,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              ModalButton(
                text: "커피챗 요청하기",
                handlePressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const ChoosePurpose();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModalButton extends StatelessWidget {
  final String text;
  final Function handlePressed;

  const ModalButton({
    super.key,
    required this.text,
    required this.handlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          handlePressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff212121),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
