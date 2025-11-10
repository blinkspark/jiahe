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
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Obx(
          () => GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final url = photos[index]['preview_url'] as Uri?;
              return Card(
                child: InkWell(
                  onTap: () {},
                  child: Image.network(url!.toString(), fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
