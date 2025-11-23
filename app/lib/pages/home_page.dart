import 'package:app/pages/albums_page.dart';
import 'package:app/pages/main_page.dart';
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
          0 => AlbumsPage(),
          1 => MainPage(),
          _ => Center(child: Text("_")),
        },
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: appState.homePageIndex.value,
          onDestinationSelected: (value) =>
              appState.homePageIndex.value = value,
          elevation: 10,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            // NavigationDestination(icon: Icon(Icons.home), label: '首页'),
            NavigationDestination(icon: Icon(Icons.photo_album), label: '相册'),
            NavigationDestination(icon: Icon(Icons.person), label: '我的'),
          ],
        ),
      ),
    );
  }
}
