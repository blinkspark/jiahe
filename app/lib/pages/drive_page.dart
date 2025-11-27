import 'package:app/controllers/drive_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';

class DrivePage extends StatefulWidget {
  const DrivePage({super.key});

  @override
  State<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends State<DrivePage> {
  final driveController = Get.put(DriveController());
  final Logger logger = Get.find();

  @override
  void initState() {
    super.initState();
    driveController.fetchObjects(driveController.currentPath.value).then((v) {
      logger.d(driveController.objectList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('网盘 ${driveController.currentPath}')),
        centerTitle: true,
      ),
      body: Obx(
        () => driveController.isFetching.value
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
              itemCount: driveController.objectList.length,
              itemBuilder: (context, index) {
                final item = driveController.objectList[index];
                return ListTile(
                  leading: item["type"] == "folder"
                      ? Icon(Icons.folder)
                      : Icon(Icons.insert_drive_file_outlined),
                  title: Text(item['name']),
                  onTap: () {},
                );
              },
            ),
      ),
    );
  }
}
