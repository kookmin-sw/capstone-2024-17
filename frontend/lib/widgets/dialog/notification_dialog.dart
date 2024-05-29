import 'package:flutter/material.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/widgets/button/bottom_two_buttons.dart';
import 'package:frontend/widgets/button/modal_button.dart';
import 'package:provider/provider.dart';

// 커피챗 요청 도착 알림창
class ArriveRequestNotification extends StatelessWidget {
  const ArriveRequestNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    return NotificationDialog(
      contents: "새로운 커피챗 요청이 \n도착했어요!",
      backButton: "닫기",
      navigateButton: "보기",
      handleNavigate: () {
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
        selectedIndexProvider.selectedIndex = 1;
        selectedIndexProvider.selectedTabIndex = 1;
      },
    );
  }
}

// 커피챗 요청 수락 알림창
class ReqAcceptedNotification extends StatelessWidget {
  final String nickname;

  const ReqAcceptedNotification({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    return NotificationDialog(
        contents: '$nickname님이 커피챗 요청을 \n수락했어요!',
        backButton: "닫기",
        navigateButton: "채팅 보기",
        handleNavigate: () {
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
          selectedIndexProvider.selectedIndex = 2;
        });
  }
}

// 커피챗 요청 거절 알림창
class ReqDeniedNotification extends StatelessWidget {
  final String nickname;

  const ReqDeniedNotification({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return NotificationDialog(
      contents: '$nickname님이 커피챗 요청을 \n거절했어요.. :(',
      backButton: "확인",
    );
  }
}

// 커피챗 종료 알림창
class ReqFinishedNotification extends StatelessWidget {
  final String nickname;

  const ReqFinishedNotification({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    return NotificationDialog(
        contents: '$nickname님이 커피챗을 \n종료했어요!',
        backButton: "닫기",
        navigateButton: "종료하기",
        handleNavigate: () {
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
          selectedIndexProvider.selectedIndex = 1;
        });
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
  // navigateButton: 필수 아님, 뒤로 간 다음 요청 화면으로 이동
  // backButton: 필수, 뒤로가기
  final String contents;
  final String backButton;
  final String? navigateButton;
  final VoidCallback? handleNavigate;

  const NotificationDialog({
    super.key,
    required this.contents,
    required this.backButton,
    this.navigateButton,
    this.handleNavigate,
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
              'assets/logo_no_background.png',
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
                (navigateButton == null)
                    ? ModalButton(
                        text: backButton,
                        handlePressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : BottomTwoButtons(
                        first: navigateButton!,
                        second: backButton,
                        handleFirstClick: () {
                          if (handleNavigate != null) {
                            handleNavigate!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        handleSecondClick: () {}),
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
                ModalButton(
                  text: button,
                  handlePressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
