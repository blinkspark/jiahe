import 'package:app/services/drive_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart';

class DriveController extends GetxController {
  final currentPath = '/'.obs;
  final objectList = <Map<String, dynamic>>[].obs;
  final DriveService driveService = Get.put(DriveService());
  final Logger logger = Get.find();
  final isFetching = false.obs;

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

  Future<void> changePath(String path) async {
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
    for (var file in files) {
      final url = await driveService.getUploadUrl(currentPath.value, file.name);
      logger.d(url);
      // logger.d(file.bytes);
      try {
        // final res = await put(
        //   Uri.parse(url),
        //   headers: {
        //     // "Content-Type": "application/octet-stream",
        //     "Content-Length": file.size.toString(),
        //   },
        //   body: file.bytes,
        // );
        final res = await Dio().put<String>(
          url,
          data: file.readStream!,
          options: Options(
            headers: {
              // "Content-Type": "application/octet-stream",
              "Content-Length": file.size,
            },
            // responseType: ResponseType.plain,
          ),
          onSendProgress: (count, total) {
            logger.d("$count/$total");
          },
        );
        logger.d(res.statusCode);
        logger.d(res.data);
      } catch (e) {
        logger.e(e);
      }
    }
  }
}
