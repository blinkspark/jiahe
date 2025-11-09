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
      title: const Text('创建相册'),
      content: TextField(decoration: const InputDecoration(hintText: '相册名称')),
      actions: [TextButton(onPressed: () {}, child: const Text('创建'))],
    );
  }
}
