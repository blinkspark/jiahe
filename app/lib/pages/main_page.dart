import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  final appState = Get.find<AppStateController>();

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
              child: Text('登录'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/album');
              },
              child: Text('相册'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.changeThemeMode(ThemeMode.light);
              },
              child: Text('亮主题'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.changeThemeMode(ThemeMode.dark);
              },
              child: Text('暗主题'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.logout();
              },
              child: Text('注销'),
            ),
          ],
        ),
      ),
    );
  }
}
