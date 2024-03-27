import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
              Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('회원가입',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ))),
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 140), // 좌우 마진 추가
                  child: Column(children: <Widget>[
                    TextField(
                      controller: _loginIdController,
                      decoration: const InputDecoration(labelText: 'Login ID'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                    ),
                  ])),
              Container(
                margin: const EdgeInsets.all(50),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        print('Login ID: ${_loginIdController.text}');
                        print('Password: ${_passwordController.text}');
                        print(
                            'Confirm Password: ${_confirmPasswordController.text}');
                      },
                      child: Text('회원가입'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signin');
                        },
                        child: const Text('로그인')),
                  ],
                ),
              ),
            ])));
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
