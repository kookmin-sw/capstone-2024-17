import 'package:flutter/material.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/button/modal_button.dart';

String reqlistpara = '';
int requestTypeId = 0;
int _selectedIndex = 0; // 선택된 인덱스를 저장할 변수
List<String> purpose = [
  "당신의 회사가 궁금해요",
  "당신의 업무가 궁금해요",
  "같이 개발 이야기 나눠요",
  "점심시간 함께 산책해요"
];

class ChoosePurpose extends StatelessWidget {
  const ChoosePurpose({
    Key? key,
  }) : super(key: key);

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
              children: [
                PurposeButton(
                  purpose: "당신의 회사가 궁금해요",
                  selectedindex: 0,
                  onIndexChanged: _updateSelectedIndex, // 함수 전달
                ),
                PurposeButton(
                  purpose: "당신의 업무가 궁금해요",
                  selectedindex: 1,
                  onIndexChanged: _updateSelectedIndex, // 함수 전달
                ),
                PurposeButton(
                  purpose: "같이 개발 이야기 나눠요",
                  selectedindex: 2,
                  onIndexChanged: _updateSelectedIndex, // 함수 전달
                ),
                PurposeButton(
                  purpose: "점심시간 함께 산책해요",
                  selectedindex: 3,
                  onIndexChanged: _updateSelectedIndex, // 함수 전달
                ),
              ],
            ),
          ),
          ModalButton(
            text: "요청 보내기",
            handlePressed: () async {
              int senderId = 6;
              int receiverId = 7;
              try {
                //로그인 한 유저의 senderId 가져오기
                Map<String, dynamic> res = await getUserDetail();
                if (res['success']) {
                  senderId = res['data']['userId'];
                } else {
                  print(
                      '로그인된 유저 정보를 가져올 수 없습니다: ${res["message"]}(${res["statusCode"]})');
                }

                Map<String, dynamic> response =
                    await matchRequest(senderId, receiverId, _selectedIndex);

                print(response);
                if (response['success'] == true) {
                  try {
                    Map<String, dynamic> inforesponse = await matchInfoRequest(
                        response['data']['matchId'],
                        response['data']['senderId'],
                        response['data']['receiverId']);

                    print("info Response: $inforesponse");
                    var nickname = inforesponse['data']['nickname'];
                    var company = inforesponse['data']['company'];
                    // var position = inforesponse['data']['position'];
                    var introduction = inforesponse['data']['introduction'];
                    double rating = inforesponse['data']['rating'] ?? 0.0;

                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => CoffeechatReqList(
                    //             receiverNickname: nickname,
                    //             receiverCompany: company,
                    //             receiverPosition: 'Position',
                    //             receiverIntroduction: introduction,
                    //             receiverRating: rating,
                    //             Question: purpose[_selectedIndex])));
                    // reqlistpara = inforesponse['data']['matchId'];
                  } catch (e) {
                    print("matchInfoRequest Error: $e");
                  }
                }
              } catch (e) {
                print("matchRequest Error: $e");
              }
            },
          )
        ],
      ),
    );
  }

  // 선택된 인덱스를 업데이트하는 함수
  void _updateSelectedIndex(int newIndex) {
    _selectedIndex = newIndex;
  }
}

class PurposeButton extends StatefulWidget {
  final String purpose;
  final int selectedindex;
  final Function(int) onIndexChanged; // 새로운 함수 추가

  const PurposeButton({
    Key? key,
    required this.purpose,
    required this.selectedindex,
    required this.onIndexChanged, // 생성자에 함수 추가
  }) : super(key: key);

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
            // 버튼이 눌리면 새로운 인덱스로 업데이트
            widget.onIndexChanged(widget.selectedindex);
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
