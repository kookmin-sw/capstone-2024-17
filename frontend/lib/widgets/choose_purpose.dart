import 'package:flutter/material.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/button/bottom_one_button.dart';
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
            handlePressed: () async {
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
                    builder: (BuildContext context) {
                      return AlertDialog(
                        // title: const Text(""),
                        content: BottomOneButton(
                          first: '커피챗 목적을 선택해주세요.',
                        ),
                      );
                    },
                  );
                  return;
                }

                Map<String, dynamic> response =
                    await matchRequest(senderId, receiverId, _selectedIndex!);

                selectedIndexProvider.selectedIndex = 1;
              } catch (e) {
                throw Error();
              }
            },
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
            fontSize: 20,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
