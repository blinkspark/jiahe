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
              // 如果正在上传，不允许重复上传
              if (appState.isUploading.value) {
                Get.snackbar('提示', '正在上传中，请稍候');
                return;
              }
              
              var res = await FilePicker.platform.pickFiles(
                withReadStream: true,
                allowMultiple: true,
              );
              
              if (res != null && res.files.isNotEmpty) {
                // 串行上传文件以显示进度
                for (var file in res.files) {
                  try {
                    await appState.createPhotoToAlbum(albumId, file);
                    // 上传成功后刷新照片列表
                    await getPhotos(albumId!);
                  } catch (e) {
                    logger.e(e);
                    Get.snackbar('错误', '上传照片失败: ${file.name}');
                  }
                }
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Obx(() => Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // 上传进度显示
            if (appState.isUploading.value) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: appState.uploadProgress.value,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appState.uploadStatus.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: appState.uploadProgress.value,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    if (appState.uploadingFiles.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        '队列中的文件: ${appState.uploadingFiles.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
            // 照片网格
            Expanded(
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
          ],
        ),
      )),
    );
  }
}
