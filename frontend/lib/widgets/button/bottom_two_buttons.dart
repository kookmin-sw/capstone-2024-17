import 'package:flutter/material.dart';

class BottomTwoButtonsSmall extends StatelessWidget {
  final String first;
  final String second;
  final Function handleFirstClick;
  final Function handleSecondClick;

  const BottomTwoButtonsSmall({
    super.key,
    required this.first,
    required this.second,
    required this.handleFirstClick,
    required this.handleSecondClick,
  });

  @override
  Widget build(BuildContext context) {
    return BottomTwoButtons(
      width: 110,
      first: first,
      second: second,
      handleFirstClick: handleFirstClick,
      handleSecondClick: handleSecondClick,
    );
  }
}

class BottomTwoButtons extends StatelessWidget {
  final double? width;
  final String first;
  final String second;
  final Function handleFirstClick;
  final Function handleSecondClick;

  const BottomTwoButtons({
    super.key,
    this.width, // width값을 지정하지 않으면 null이 됨
    required this.first,
    required this.second,
    required this.handleFirstClick,
    required this.handleSecondClick,
  });

  @override
  Widget build(BuildContext context) {
    return (width == null)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    handleFirstClick();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff212121),
                  ),
                  child: Text(
                    first,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    handleSecondClick();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    /*
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      )
                    */
                  ),
                  child: Text(
                    second,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    handleFirstClick();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff212121),
                  ),
                  child: Text(
                    first,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(
                width: width,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    handleSecondClick();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    /*
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      )
                    */
                  ),
                  child: Text(
                    second,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          );
  }
}
