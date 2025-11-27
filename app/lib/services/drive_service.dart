import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DriveService extends GetxService {
  final Logger logger = Get.find();
  final PocketBase pb = Get.find();

  Future<List<Map<String, dynamic>>> getObjectList(String path) async {
    final res = await pb
        .collection("objects")
        .getFullList(filter: "parent.name = '$path'", sort: "-type,name");
    return res.map((item) {
      if (item.getStringValue("type") == "folder"){
        final name = item.getStringValue("name");
        final endName = name.split("/").last;
        item.data["name"] = endName;
      }
      return item.data;
    }).toList();
  }
}
