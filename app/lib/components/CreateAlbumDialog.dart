import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CreateAlbumDialog extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();

  CreateAlbumDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: [
          Icon(Icons.photo_album, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text('创建相册'),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('创建'),
        ),
      ],
    );
  }
}
