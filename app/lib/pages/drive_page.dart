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
        actions: [
          IconButton(
            onPressed: () {
              final path = driveController.currentPath.value;
              final splitedPath = path.split('/');
              if (splitedPath.length > 1) {
                final newPath = path.substring(0, path.lastIndexOf('/'));
                driveController.changePath(newPath == '' ? '/' : newPath);
              }
            },
            icon: Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: () {
              driveController.fetchObjects(driveController.currentPath.value);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
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
                    title: Text(
                      item["type"] == "folder"
                          ? item['display_name']
                          : item['name'],
                    ),
                    onTap: () {
                      if (item["type"] == "folder") {
                        driveController.changePath(item['name']);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
