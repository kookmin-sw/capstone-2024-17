import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screen/user_screen.dart';
import 'package:frontend/user_model.dart';
import 'package:frontend/widgets/alert_dialog_widget.dart';
import 'package:frontend/widgets/kakao_login_widget.dart';
import 'package:frontend/login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    LoginViewModel _loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    if (_loginViewModel.user != null) {
      // 현재 페이지를 대신해 유저 페이지로 navigate
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UserScreen()));
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '로그인',
            style: TextStyle(fontSize: 24),
          ),
          toolbarHeight: 100,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              // 로그인 정보 표시
              Text('로그인 상태: ${_loginViewModel.user?.loginId}'),
              Text(
                '닉네임: ${_loginViewModel.user?.nickname}',
              ),
              Text(
                '로그인 타입: ${_loginViewModel.user?.loginType}',
              ),

              // storage 정보 표시
              ElevatedButton(
                  onPressed: () async {
                    final storageData = await storage.readAll();
                    print('스토리지: ${storageData.toString()}');
                  },
                  child: const Text(
                    "스토리지 콘솔에 출력",
                    style: TextStyle(fontSize: 14),
                  )),

              // 일반 로그인 컨테이너
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 20), // 마진 추가
                  child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _loginIdController,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            labelText: '아이디',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            // border: OutlineInputBorder(),
                            labelText: '비밀번호',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_loginIdController.text == '') {
                              showAlertDialog(context, '아이디를 입력해주세요.');
                            } else if (_passwordController.text == '') {
                              showAlertDialog(context, '비밀번호를 입력해주세요.');
                            } else {
                              try {
                                await login(
                                  context,
                                  _loginIdController.text,
                                  _passwordController.text,
                                );
                              } catch (error) {
                                showAlertDialog(context, '요청 실패: $error');
                              }
                              setState(() {}); // 화면 갱신
                            }
                          },
                          child: Text('로그인'),
                        ),
                      ])),

              // 버튼 컨테이너
              Container(
                  margin: const EdgeInsets.all(35),
                  child: Column(
                    children: <Widget>[
                      // 카카오톡 로그인 버튼
                      InkWell(
                        onTap: () async {
                          // setState(() => {});  // 화면 갱신
                        },
                        child: KakaoLoginWidget(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // 로그아웃 버튼
                      ElevatedButton(
                        onPressed: () async {
                          await logout(context);
                          setState(() {}); // 화면 갱신
                        },
                        child: const Text('로그아웃'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('회원가입')),
                    ],
                  ))
            ])));
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login(
    BuildContext context,
    String loginId,
    String password,
  ) async {
    LoginViewModel _loginViewModel =
        Provider.of<LoginViewModel>(context, listen: false);
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final url = Uri.parse('http://localhost:8080/auth/signIn');
    // final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');
    final data = jsonEncode({
      'loginId': loginId,
      'password': hashedPassword,
    });
    // setState(() {});
    try {
      http.Response res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: data);
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // 요청 성공
        // storage에는 userUUID와 토큰 저장
        await storage.write(
            key: 'userUUID', value: jsonData["data"]["userUUID"]);
        await storage.write(
            key: 'authToken', value: jsonData["data"]["authToken"]);
        // 아이디와 닉네임, 로그인타입으로 UserModel 만들어서 provider에 로그인
        UserModel user = UserModel(loginId, 'none', 'none');
        _loginViewModel.login(user);
        showAlertDialog(context, '로그인 성공!');
        // 현재 페이지를 대신해 유저 페이지로 navigate
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UserScreen()));
      } else {
        // 로그인 예외처리
        showAlertDialog(
            context, '로그인 실패: ${jsonData["message"]}(${jsonData["code"]})');
      }
      // 에러
    } catch (error) {
      showAlertDialog(context, '로그인 실패: $error');
    }
  }
}
