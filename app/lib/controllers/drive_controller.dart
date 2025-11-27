import 'package:app/services/drive_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
}
