import 'package:app/controllers/drive_controller.dart';
import 'package:app/pages/photo_view_page.dart';
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
      bottomSheet: Obx(() {
        if (driveController.uploading.value) {
          return SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                value: driveController.uploadProgress.value,
              ),
            ),
          );
        }
        if (driveController.downloading.value) {
          return SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                value: driveController.downloadProgress.value,
              ),
            ),
          );
        }
        return SizedBox.shrink();
      }),
      appBar: AppBar(
        title: Obx(() => Text('网盘 ${driveController.currentPath}')),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              driveController.fetchObjects(driveController.currentPath.value);
            },
            tooltip: "刷新",
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
                driveController.changeCurrentPath(newPath);
              }
            },
            tooltip: "上级目录",
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
            tooltip: '新建文件夹',
            icon: Icon(Icons.create_new_folder),
          ),
          IconButton(
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowMultiple: true,
                withReadStream: true,
                // withData: true,
              );
              logger.d(res);
              if (res == null) return;
              driveController.uploadFiles(res.files);
            },
            tooltip: '上传文件',
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
                    leading: Icon(getIcon(item['type'], item['name'])),
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        switch (value) {
                          case "delete":
                            final res = await Get.dialog(
                              AlertDialog(
                                title: Text('确认'),
                                content: Text('确定删除吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back(result: false);
                                    },
                                    child: Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back(result: true);
                                    },
                                    child: Text(
                                      '确定',
                                      style: TextStyle(
                                        color: Get.theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (res == true) {
                              driveController.deleteObject(item['id']);
                            }
                            break;
                          case "download":
                            driveController.downloadFile(
                              item['id'],
                              item['name'],
                            );
                            break;
                        }
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
                          if (item["type"] != "folder")
                            PopupMenuItem(
                              value: "download",
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text("下载"),
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
                    subtitle: item["type"] == "file"
                        ? Text(displaySize(item['size']))
                        : null,
                    onTap: () {
                      if (item["type"] == "folder") {
                        driveController.changeCurrentPath(item['name']);
                      } else {
                        onFileTap(item);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  void onFileTap(Map<String, dynamic> item) async {
    final ext = item['name'].split('.').last;
    switch (ext) {
      case "png":
      case "jpg":
      case "jpeg":
      case "gif":
        onPicTap(item);
        break;
    }
  }

  void onPicTap(Map<String, dynamic> item) {
    final pics = driveController.objectList.where((obj) {
      final ext = obj['name'].split('.').last;
      if (["png", "jpg", "jpeg", "gif"].contains(ext)) {
        return true;
      }
      return false;
    }).toList();
    final index = pics.indexWhere((element) => element['id'] == item['id']);
    Get.to(
      () => PhotoViewPage(
        photos: pics.obs,
        index: index >= 0 ? index : 0,
        isNew: true,
      ),
    );
  }

  IconData getIcon(String type, String name) {
    if (type == "folder") {
      return Icons.folder_outlined;
    } else {
      final ext = name.split('.').last;
      switch (ext) {
        case "png":
        case "jpg":
        case "jpeg":
        case "gif":
          return Icons.image;
        case "mp4":
        case "mkv":
        case "avi":
        case "mov":
          return Icons.video_collection;
        case "mp3":
        case "wav":
        case "flac":
          return Icons.audio_file;
        case "pdf":
          return Icons.picture_as_pdf;
        case "txt":
          return Icons.text_snippet;
        default:
          return Icons.insert_drive_file;
      }
    }
  }

  // 显示可阅读的文件大小
  String displaySize(int size) {
    if (size < 1024) {
      return "${size}B";
    } else if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(2)}KB";
    } else if (size < 1024 * 1024 * 1024) {
      return "${(size / 1024 / 1024).toStringAsFixed(2)}MB";
    } else if (size < 1024 * 1024 * 1024 * 1024) {
      return "${(size / 1024 / 1024 / 1024).toStringAsFixed(2)}GB";
    } else {
      return "${(size / 1024 / 1024 / 1024 / 1024).toStringAsFixed(2)}TB";
    }
  }
}
