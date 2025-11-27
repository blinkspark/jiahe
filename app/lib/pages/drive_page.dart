import 'package:app/controllers/drive_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrivePage extends StatelessWidget {
  DrivePage({super.key});

  final driveController = Get.put(DriveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('网盘'), centerTitle: true),
      body: const Center(child: Text('Drive Page')),
    );
  }
}
