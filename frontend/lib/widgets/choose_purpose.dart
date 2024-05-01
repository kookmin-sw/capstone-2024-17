import 'package:flutter/material.dart';
import 'package:frontend/screen/coffeechat_req_list.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/widgets/button/modal_button.dart';

String reqlistpara = '';

class ChoosePurpose extends StatelessWidget {
  const ChoosePurpose({
    super.key,
  });

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
          const Expanded(
              child: Column(
            children: [
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
          )),
          ModalButton(
            text: "요청 보내기",
            handlePressed: () async {
              // senderId와 receiverId 임의로 설정
              int? senderId = 2;
              int? receiverId = 3;

              try {
                Map<String, dynamic> response =
                    await matchRequest(senderId, receiverId);

                if (response['success'] == true) {
                  try {
                    Map<String, dynamic> inforesponse = await matchInfoRequest(
                        response['data']['matchId'],
                        response['data']['senderId'],
                        response['data']['receiverId']);
                    reqlistpara = inforesponse['data']['matchId'];
                    print("info Response: $inforesponse");
                  } catch (e) {
                    print("matchInfoRequest Error: $e");
                  }
                }

                print("Response: $response");

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        //커피챗 요청 목록의 보낸 요청으로 이동됨
                        builder: (context) =>
                            CoffeechatReqList(matchId: reqlistpara)));
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
