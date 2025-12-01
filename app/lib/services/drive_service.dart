import 'dart:typed_data';

import 'package:app/services/user_service.dart';
import 'package:dio/dio.dart';
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
        final displayName = name.split("/").last;
        item.data["display_name"] = displayName;
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
            "owner": userService.getUserID(),
          },
        );
  }

  Future<String> getUploadUrl(String path, String name) async {
    var nPath = "$path/$name";
    if (nPath.startsWith("//")) {
      nPath = nPath.substring(1);
    }
    logger.d("nPath $nPath");

    final encoded = Uri.encodeComponent(nPath);
    logger.d("encoded $encoded");

    final res = await pb.send<String>("/presign/$encoded");

    logger.d(res);
    return res;
  }

  Future<void> createObject(String path, String name, int size) async {
    var key = [path, name].join("/");
    if (key.startsWith("//")) {
      key = key.substring(1);
    }
    final parent = await pb
        .collection("objects")
        .getFirstListItem("name = '$path'");
    logger.d("parent $parent");
    await pb
        .collection("objects")
        .create(
          body: {
            "name": name,
            "type": "file",
            "key": key,
            "owner": userService.getUserID(),
            "parent": parent.id,
            "size": size,
          },
        );
  }

  Future<void> deleteObject(String id) async {
    await pb.collection("objects").delete(id);
  }

  Future<Uint8List?> downloadFile(
    String id,
    Function(int count, int total)? cb,
  ) async {
    final encID = Uri.encodeComponent(id);
    final res = await pb.send<String>("down_url/$encID");
    logger.d(res);
    final down = await Dio().get<Uint8List>(
      res,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (count, total) {
        cb?.call(count, total);
      },
    );
    return down.data;
  }
}
