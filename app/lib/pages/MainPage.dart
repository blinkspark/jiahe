import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  final appState = Get.find<StateController>();

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("主页"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Obx(() => Text('Is LogIn: ${appState.isLogin}')),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/login');
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.logout();
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
