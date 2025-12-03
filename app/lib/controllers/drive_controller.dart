import 'package:app/services/drive_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/v4.dart';

class DriveController extends GetxController {
  final currentPath = '/'.obs;
  final objectList = <Map<String, dynamic>>[].obs;
  final DriveService driveService = Get.put(DriveService());
  final Logger logger = Get.find();
  final isFetching = false.obs;

  final uploading = false.obs;
  final uploadProgress = 0.0.obs;

  final downloading = false.obs;
  final downloadProgress = 0.0.obs;

  final allFolders = <String>[].obs;
  final fetchingFolders = false.obs;

  Future<void> fetchObjects(String path) async {
    isFetching.value = true;
    try {
      objectList.value = await driveService.getObjectList(path);
    } catch (e) {
      logger.e(e);
      Get.snackbar(
        "错误",
        e.toString(),
        // borderColor: Get.theme.colorScheme.error,
      );
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> changeCurrentPath(String path) async {
    currentPath.value = path;
    await fetchObjects(path);
  }

  Future<void> createFolder(String name) async {
    try {
      isFetching.value = true;
      await driveService.createFolder(currentPath.value, name);
    } catch (e) {
      logger.e(e);
      Get.snackbar("错误", e.toString());
    } finally {
      isFetching.value = false;
    }
    await fetchObjects(currentPath.value);
  }

  Future<void> uploadFiles(List<PlatformFile> files) async {
    uploading.value = true;
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final uuid = UuidV4().generate();
      final url = await driveService.getUploadUrl(
        currentPath.value,
        uuid,
        file.name,
      );

      try {
        await Dio().put<String>(
          url,
          data: file.readStream!,
          options: Options(headers: {"Content-Length": file.size}),
          onSendProgress: (count, total) {
            uploadProgress.value = count / total;
          },
        );
        await driveService.createObject(
          currentPath.value,
          uuid,
          file.name,
          file.size,
        );
      } catch (e) {
        logger.e(e);
      }
    }
    uploading.value = false;
    try {
      logger.d("refresh object list");
      await fetchObjects(currentPath.value);
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> deleteObject(String id) async {
    try {
      await driveService.deleteObject(id);
    } catch (e) {
      logger.e(e);
      Get.snackbar("删除错误", e.toString());
    }
    try {
      await fetchObjects(currentPath.value);
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> downloadFile(String id, String name) async {
    try {
      downloading.value = true;
      final res = await driveService.downloadFile(id, (count, total) {
        downloadProgress.value = count / total;
      });
      if (res == null) {
        throw Exception("下载失败");
      }
      await FilePicker.platform.saveFile(fileName: name, bytes: res);
    } catch (e) {
      logger.e(e);
      Get.snackbar("下载错误", e.toString());
    } finally {
      downloading.value = false;
    }
  }

  Future<void> renameObject(String id, String name) async {
    try {
      await driveService.renameObject(id, name);
    } catch (e) {
      logger.e(e);
      Get.snackbar("重命名错误", e.toString());
    }
  }

  Future<void> moveObject(String id, String path) async {
    try {
      await driveService.moveObject(id, path);
    } catch (e) {
      logger.e(e);
      Get.snackbar("移动错误", e.toString());
    }
  }

  Future<void> fetchAllFolders() async {
    try {
      fetchingFolders.value = true;
      allFolders.value = await driveService.getAllFolders();
      logger.d(allFolders);
    } catch (e) {
      logger.e(e);
      Get.snackbar("错误", e.toString());
    } finally {
      fetchingFolders.value = false;
    }
  }
}
