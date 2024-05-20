import 'package:flutter/material.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
import 'package:frontend/screen/matching_screen.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/button/modal_button.dart';

String reqlistpara = '';
int requestTypeId = 0;
int _selectedIndex = -1; // 선택된 인덱스를 저장할 변수, 초기값은 선택되지 않은 상태를 의미

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
                  isSelected: _selectedIndex == index,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index;
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

                if (_selectedIndex == -1) {
                  print('목적을 선택하지 않았습니다');
                  return;
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

                    var nickname = inforesponse['data']['receiverInfo']
                            ['nickname'] ??
                        "nickname";
                    var company = inforesponse['data']['receiverInfo']
                            ['company']['name'] ??
                        "company";
                    var position = inforesponse['data']['receiverInfo']
                            ['position'] ??
                        "position";
                    var introduction = inforesponse['data']['receiverInfo']
                            ['introduction'] ??
                        "introduction";
                    double rating = inforesponse['data']['receiverInfo']
                            ['coffeeBean'] ??
                        0.0;

                    int requestType =
                        int.parse(inforesponse['data']['requestTypeId'] ?? '0');

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CoffeechatReqList(
                                  receiverNickname: nickname,
                                  receiverCompany: company,
                                  receiverPosition: position,
                                  receiverIntroduction: introduction,
                                  receiverRating: rating,
                                  Question: purpose[requestType],
                                  matchId: response['data']['matchId'],
                                )));
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
