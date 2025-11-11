import 'package:app/pages/photo_view_page.dart';
import 'package:app/state.dart';
import 'package:app/components/photo_grid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AlbumViewPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  final photos = <Map<String, Object>>[].obs;
  AlbumViewPage({super.key});

  Future<void> getPhotos(String albumId) async {
    try {
      photos.value = await appState.fetchAlbumPhotos(albumId);
      logger.d(photos);
    } catch (e) {
      Get.snackbar('错误', '获取相册照片失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d(Get.parameters);
    final albumId = Get.parameters['id'];
    final name = Get.parameters['name'];
    getPhotos(albumId!);
    return Scaffold(
      appBar: AppBar(
        title: Text(name!),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              var res = await FilePicker.platform.pickFiles(
                withReadStream: true,
              );
              res?.files.forEach((file) async {
                try {
                  await appState.createPhotoToAlbum(albumId, file);
                } catch (e) {
                  logger.e(e);
                  Get.snackbar('错误', '上传照片失败');
                }
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: PhotoGrid(
          photos: photos,
          onTap: (index) {
            Get.to(PhotoViewPage(photos: photos, index: index));
          },
          onLongPress: (index) {
            logger.d('TODO: long press');
          },
          logger: logger,
        ),
      ),
    );
  }
}
