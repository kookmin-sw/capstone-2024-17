import 'package:flutter/material.dart';
import 'package:frontend/widgets/button/bottom_two_buttons.dart';
import 'package:frontend/widgets/button/modal_button.dart';

// 커피챗 요청 도착 알림창
class ArriveRequestNotification extends StatelessWidget {
  const ArriveRequestNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationDialog(
      contents: "새로운 커피챗 요청이 \n도착했어요!",
      firstButton: "보기",
      secondButton: "닫기",
    );
  }
}

// 커피챗 요청 수락 알림창
class ReqAcceptedNotification extends StatelessWidget {
  const ReqAcceptedNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationDialog(
      contents: "OO 님이 커피챗 요청을 \n수락했어요!",
      firstButton: "확인",
    );
  }
}

// 커피챗 요청 거절 알림창
class ReqDeniedNotification extends StatelessWidget {
  const ReqDeniedNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationDialog(
      contents: "OO 님이 커피챗 요청을 \n거절했어요.. :(",
      firstButton: "확인",
    );
  }
}

// 오프라인 전환 알림창
class OfflineNotification extends StatelessWidget {
  const OfflineNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationDialogLong(
      title: "카페를 지정해주세요!",
      contents: "지정한 카페가 반경에서 벗어나 \n오프라인 상태로 바뀌었어요! 카페를 \n다시 지정해 주세요.",
      button: "확인",
    );
  }
}

class NotificationDialog extends StatelessWidget {
  final String contents;
  final String firstButton;
  final String? secondButton;

  const NotificationDialog({
    super.key,
    required this.contents,
    required this.firstButton,
    this.secondButton,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -50,
            left: 110,
            child: Image.asset(
              'assets/logo.png',
              width: 80,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            width: 300,
            height: 210,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  contents,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                (secondButton == null)
                    ? ModalButton(text: firstButton, handlePressed: () {})
                    : BottomTwoButtonsSmall(
                        first: firstButton,
                        second: secondButton!,
                        handleFirstClick: () {},
                        handleSecondClick: () {},
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationDialogLong extends StatelessWidget {
  final String title;
  final String contents;
  final String button;

  const NotificationDialogLong({
    super.key,
    required this.title,
    required this.contents,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -50,
            left: 110,
            child: Image.asset(
              'assets/logo.png',
              width: 80,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 25, right: 25, bottom: 20),
            width: 300,
            height: 300,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  contents,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const Expanded(child: SizedBox()),
                ModalButton(text: button, handlePressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}