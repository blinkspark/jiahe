import 'package:app/services/user_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DriveService extends GetxService {
  final Logger logger = Get.find();
  final PocketBase pb = Get.find();
  final UserService userService = Get.put(UserService());

  Future<List<Map<String, dynamic>>> getObjectList(String path) async {
    final res = await pb
        .collection("objects")
        .getFullList(filter: "parent.name = '$path'", sort: "-type,name");
    return res.map((item) {
      if (item.getStringValue("type") == "folder") {
        final name = item.getStringValue("name");
        final endName = name.split("/").last;
        item.data["display_name"] = endName;
      }
      return item.data;
    }).toList();
  }

  Future<void> createFolder(String path, String name) async {
    var nPath = "$path/$name";
    if (nPath.startsWith("//")) {
      nPath = nPath.substring(1);
    }
    var exists = false;
    try {
      await pb.collection("objects").getFirstListItem("name = '$nPath'");
      exists = true;
      // ignore: empty_catches
    } catch (e) {}
    if (exists) {
      throw Exception("Folder already exists");
    }

    final parent = await pb
        .collection("objects")
        .getFirstListItem("name = '$path'");
    logger.d("parent $parent");

    await pb
        .collection("objects")
        .create(
          body: {
            "name": nPath,
            "type": "folder",
            "parent": parent.id,
            "owner": (await userService.getUserID())!,
          },
        );
  }
}
