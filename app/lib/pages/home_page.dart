import 'package:app/pages/chats_page.dart';
import 'package:app/pages/drive_page.dart';
import 'package:app/pages/config_page.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final AppStateController appState = Get.find();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => switch (appState.homePageIndex.value) {
          0 => ChatsPage(),
          1 => DrivePage(),
          2 => ConfigPage(),
          _ => Center(child: Text("You should not see this.")),
        },
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: appState.homePageIndex.value,
          onDestinationSelected: (value) =>
              appState.homePageIndex.value = value,
          elevation: 10,
          destinations: [
            // NavigationDestination(icon: Icon(Icons.home), label: '首页'),
            NavigationDestination(icon: Icon(Icons.chat), label: '聊天'),
            NavigationDestination(icon: Icon(Icons.cloud), label: '网盘'),
            NavigationDestination(icon: Icon(Icons.person), label: '我的'),
          ],
        ),
      ),
    );
  }
}
