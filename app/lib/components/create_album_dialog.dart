import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CreateAlbumDialog extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  final nameController = TextEditingController();

  CreateAlbumDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        children: [
          Icon(Icons.photo_album, color: Get.theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('创建相册'),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: '相册名称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Get.theme.colorScheme.surface,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        ElevatedButton(
          onPressed: () async {
            try {
              logger.d(nameController.text);
              if (nameController.text.isEmpty) {
                Get.snackbar('失败', '相册名称不能为空');
                return;
              }
              await appState.createAlbum(nameController.text);
              Get.back();
              Get.snackbar('成功', '相册创建成功');
            } catch (e) {
              Get.back();
              Get.snackbar('失败', '相册创建失败');
              logger.e(e);
            }
          },
          child: const Text('创建'),
        ),
      ],
    );
  }
}
