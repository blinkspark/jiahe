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
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Obx(
                () =>
                    Text('Is LogIn: ${appState.isLogin} ${appState.username}'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/login');
                },
                child: Text('登录'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/follows');
                },
                child: Text('关注'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/albums');
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
                onPressed: () async {
                  final res = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text('提示'),
                      content: Text('确定要注销吗？'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back(result: false);
                          },
                          child: Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back(result: true);
                          },
                          child: Text('确定'),
                        ),
                      ],
                    ),
                  );
                  if (res == true) appState.logout();
                },
                child: Text('注销'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
