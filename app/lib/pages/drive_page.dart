import 'package:app/controllers/drive_controller.dart';
import 'package:file_picker/file_picker.dart';
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
    driveController.fetchObjects(driveController.currentPath.value);
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
              driveController.fetchObjects(driveController.currentPath.value);
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              final path = driveController.currentPath.value;
              if (path == '/') return;
              final splitedPath = path.split('/');
              if (splitedPath.length > 1) {
                var newPath = path.substring(0, path.lastIndexOf('/'));
                newPath = newPath.isEmpty ? '/' : newPath;
                driveController.changePath(newPath);
              }
            },
            icon: Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: () async {
              final nameController = TextEditingController();
              await Get.dialog(
                AlertDialog(
                  title: Text('新建文件夹'),
                  content: TextField(controller: nameController),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        logger.d(nameController.text);
                        driveController.createFolder(nameController.text);
                        Get.back();
                      },
                      child: Text('确定'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.create_new_folder),
          ),
          IconButton(
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.any,
                withReadStream: true,
                // withData: true,
              );
              logger.d(res);
              if (res == null) return;
              driveController.uploadFiles(res.files);
            },
            icon: Icon(Icons.upload_file),
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
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        logger.d(value);
                      },
                      itemBuilder: (ctx) {
                        return [
                          PopupMenuItem(
                            value: "delete",
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text("删除"),
                            ),
                          ),
                        ];
                      },
                    ),
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
