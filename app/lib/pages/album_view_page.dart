import 'package:app/state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:pocketbase/pocketbase.dart';

class AlbumViewPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  AlbumViewPage({super.key});

  Future<void> getPhotos(String albumId) async {
    final photos = await appState.fetchAlbumPhotos(albumId);
    logger.d(photos);
  }

  @override
  Widget build(BuildContext context) {
    final albumId = Get.parameters['id'];
    getPhotos(albumId!);
    return Scaffold(
      appBar: AppBar(
        title: Text('Album View'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              var res = await FilePicker.platform.pickFiles(withData: true);
              res?.files.forEach((file) {
                logger.d(file);
                appState.addFileToAlbum(albumId, file);
              });
            },
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: Center(child: Text('Album View $albumId')),
    );
  }
}
