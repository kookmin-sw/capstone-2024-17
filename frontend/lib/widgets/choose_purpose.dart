import 'package:flutter/material.dart';

class ChoosePurpose extends StatelessWidget {
  const ChoosePurpose({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      padding: const EdgeInsets.all(25),
      width: 350,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text(
            "커피챗 목적 선택",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(
            height: 15,
          ),
          PurposeButton(
            purpose: "당신의 회사가 궁금해요",
          ),
          PurposeButton(
            purpose: "당신의 업무가 궁금해요",
          ),
          PurposeButton(
            purpose: "같이 개발 이야기 나눠요",
          ),
          PurposeButton(
            purpose: "점심시간 함께 산책해요",
          ),
        ],
      ),
    ));
  }
}

class PurposeButton extends StatefulWidget {
  final String purpose;

  const PurposeButton({
    super.key,
    required this.purpose,
  });

  @override
  State<PurposeButton> createState() => _PurposeButtonState();
}

class _PurposeButtonState extends State<PurposeButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 280,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isPressed = !isPressed;
          });
        },
        style: ButtonStyle(
          backgroundColor: isPressed
              ? MaterialStateProperty.all(const Color(0xffff916f))
              : MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.all(const BorderSide(
            color: Color(0xffff6C3e),
          )),
          overlayColor: MaterialStateColor.resolveWith(
            (states) => Colors.transparent,
          ),
          shadowColor: MaterialStateColor.resolveWith(
            (states) => Colors.transparent,
          ),
        ),
        child: Text(
          "# ${widget.purpose}",
          style: TextStyle(
            fontSize: 20,
            color: isPressed ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
