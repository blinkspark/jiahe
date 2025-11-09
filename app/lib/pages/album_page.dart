import 'package:app/components/create_album_dialog.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AlbumPage extends StatelessWidget {
  final appState = Get.find<AppStateController>();
  final logger = Get.find<Logger>();
  AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('相册'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.dialog(CreateAlbumDialog());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Center(child: Column(children: [])),
    );
  }
}
