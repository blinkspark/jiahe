import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumViewPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  AlbumViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Album View')),
      body: Center(child: Text('Album View ${Get.parameters['id']}')),
    );
  }
}
