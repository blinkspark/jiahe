import 'dart:typed_data';

import 'package:app/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DriveService extends GetxService {
  final Logger logger = Get.find();
  final PocketBase pb = Get.find();
  final UserService userService = Get.put(UserService());
  final GetStorage cacheStorage = GetStorage('DriveCache');

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

  Future<String> getUploadUrl(String path, String uuid, String name) async {
    var nPath = "$path/$uuid/$name";
    nPath = nPath.replaceAll("//", "/");

    final encoded = Uri.encodeComponent(nPath);
    logger.d("encoded $encoded");

    final res = await pb.send<String>("/presign/$encoded");

    logger.d(res);
    return res;
  }

  Future<void> createObject(
    String path,
    String uuid,
    String name,
    int size,
  ) async {
    var key = [path, uuid, name].join("/");
    key = key.replaceAll("//", "/");
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
    final res = await getDownloadUrl(id);
    final down = await Dio().get<Uint8List>(
      res,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (count, total) {
        cb?.call(count, total);
      },
    );
    return down.data;
  }

  Future<String> getDownloadUrl(String id) async {
    final data = cacheStorage.read<Map<String, dynamic>>("download_url/$id");
    if (data != null &&
        DateTime.parse(data['expires']).isAfter(DateTime.now())) {
      return data['url'];
    }
    final encID = Uri.encodeComponent(id);
    final url = await pb.send<String>("down_url/$encID");
    final expires = DateTime.now().add(Duration(hours: 3)).toIso8601String();
    cacheStorage.write("download_url/$id", {'url': url, 'expires': expires});
    return url;
  }

  Future<void> renameObject(String id, String name) async {
    await pb.collection("objects").getOne(id);
    await pb.collection("objects").update(id, body: {"name": name});
  }

  Future<void> moveObject(String id, String path) async {
    final parent = await pb
        .collection("objects")
        .getFirstListItem("name = '$path'");
    final object = await pb.collection("objects").getOne(id);
    var key = [path, object.getStringValue("name")].join("/");
    key = key.replaceAll("//", "/");

    await pb.collection("objects").update(id, body: {"parent": parent.id});
  }

  Future<List<String>> getAllFolders() async {
    final res = await pb
        .collection("objects")
        .getFullList(filter: "type = 'folder'", sort: "name");
    return res.map((item) => item.getStringValue("name")).toList();
  }
}
