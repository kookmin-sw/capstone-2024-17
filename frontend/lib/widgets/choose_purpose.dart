import 'package:flutter/material.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/dialog/one_button_dialog.dart';
import 'package:frontend/widgets/dialog/yn_dialog.dart';
import 'package:frontend/widgets/button/modal_button.dart';
import 'package:provider/provider.dart';

List<String> purpose = [
  "당신의 회사가 궁금해요",
  "당신의 업무가 궁금해요",
  "같이 개발 이야기 나눠요",
  "점심시간 함께 산책해요"
];

class ChoosePurpose extends StatefulWidget {
  final int userId; // receiverId 추가

  const ChoosePurpose({
    super.key,
    required this.userId, // 생성자에 receiverId 추가
  });

  @override
  _ChoosePurposeState createState() => _ChoosePurposeState();
}

class _ChoosePurposeState extends State<ChoosePurpose> {
  int? _selectedIndex;
  late SelectedIndexModel selectedIndexProvider;

  @override
  void initState() {
    super.initState();
    selectedIndexProvider =
        Provider.of<SelectedIndexModel>(context, listen: false);
  }

  // '요청 보내기' 버튼 클릭 핸들러
  void handleSendRequest() async {
    final receiverId = widget.userId;
    int senderId = 0; // 초기화

    try {
      //로그인 한 유저의 senderId 가져오기
      Map<String, dynamic> res = await getUserDetail();
      if (res['success']) {
        senderId = res['data']['userId'];
      } else {
        print(
            '로그인된 유저 정보를 가져올 수 없습니다: ${res["message"]}(${res["statusCode"]})');
        return;
      }

      if (_selectedIndex == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) => const OneButtonDialog(
            content: "커피챗 목적을 선택해주세요.",
          ),
        );
        return;
      }

      Map<String, dynamic> reqInfo = await requestInfoRequest(senderId);

      // 기존에 보낸 요청이 있는 경우 - 취소하고 보낼지 확인
      if (reqInfo['data'].length > 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) => YesOrNoDialog(
            content: "이미 보낸 요청이 있어요! \n기존 요청을 취소하고 보낼까요?",
            firstButton: "네",
            secondButton: "아니요",
            handleFirstClick: () {
              // 기존 요청 취소하기
              matchCancelRequest(reqInfo['data'][0]['matchId']);
              // 새로운 요청 보내기
              matchRequest(senderId, receiverId, _selectedIndex!);

              Navigator.of(context).pop();
              Navigator.of(context).pop();
              selectedIndexProvider.selectedIndex = 1;
            },
            handleSecondClick: () {
              Navigator.of(context).pop();
            },
          ),
        );
        return;
      }
      // 기존에 보낸 요청 없는 경우 - 바로 요청 보내기
      else {
        matchRequest(senderId, receiverId, _selectedIndex!);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        selectedIndexProvider.selectedIndex = 1;
      }
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      width: 350,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "커피챗 목적 선택",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Column(
              children: List.generate(purpose.length, (index) {
                return PurposeButton(
                  purpose: purpose[index],
                  isSelected: _selectedIndex != null && _selectedIndex == index,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index; // 선택한 목적의 인덱스 업데이트
                    });
                  },
                );
              }),
            ),
          ),
          ModalButton(
            text: "요청 보내기",
            handlePressed: handleSendRequest,
            buttonColor: _selectedIndex != null
                ? Colors.black
                : Colors.grey, // 배경색 조건에 따라 동적으로 설정
          )
        ],
      ),
    );
  }
}

class PurposeButton extends StatelessWidget {
  final String purpose;
  final bool isSelected;
  final VoidCallback onPressed;

  const PurposeButton({
    super.key,
    required this.purpose,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get the width of the device
    double deviceWidth = MediaQuery.of(context).size.width;

    // Adjust the font size based on the width of the device
    double fontSize = deviceWidth * 0.05; // Example: 5% of the device width

    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 280,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: isSelected
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
          "# $purpose",
          style: TextStyle(
            fontSize: fontSize,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
