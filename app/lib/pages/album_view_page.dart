import 'package:app/state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';

class AlbumViewPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  AlbumViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final albumId = Get.parameters['id'];
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
                appState.addFileToAlbum(albumId!, file);
              });
            },
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: Center(
        child: albumId == null
            ? const Text('Album not found')
            : Text('Album View $albumId'),
      ),
    );
  }
}
