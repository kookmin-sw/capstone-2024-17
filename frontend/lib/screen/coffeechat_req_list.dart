import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CoffeechatReqList());
  }
}

class CoffeechatReqList extends StatelessWidget {
  const CoffeechatReqList({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: AppBar(
              title: const Text(
                "커피챗 요청 목록",
                style: TextStyle(fontSize: 24),
              ),
              toolbarHeight: 100,
              backgroundColor: Colors.white,
              leading: const Icon(Icons.arrow_back_ios),
              leadingWidth: 70,
            ),
          ),
          body: Column(
            children: [
              const TabBar(tabs: [
                Tab(text: '보낸 요청'),
                Tab(text: '받은 요청'),
              ]),
              Expanded(
                child: TabBarView(children: [
                  const Text("보낸 요청"),
                  ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return const ListTile(
                        title: Text('받은 요청'),
                      );
                    },
                  ),
                ]),
              ),
            ],
          )),
    );
  }
}
