import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class AppStateController extends GetxController {
  final isLogin = false.obs;
  final _box = GetStorage();
  late final AsyncAuthStore _authStore;
  late final PocketBase _pb;
  late final Logger logger;

  // 上传状态管理
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;
  final uploadingFiles = <String>[].obs;
  final uploadStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    logger = Get.find<Logger>();
    _authStore = AsyncAuthStore(
      save: (String data) async => _box.write('pb_auth', data),
      initial: _box.read<String>('pb_auth'),
    );
    _pb = PocketBase(dotenv.get('BASE_URL'), authStore: _authStore);
    isLogin.value = _pb.authStore.isValid;
    _pb.authStore.onChange.listen((data) {
      isLogin.value = _pb.authStore.isValid;
    });
  }

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  Future<void> logout() async {
    _pb.authStore.clear();
  }

  Future<void> register(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    await _pb
        .collection('users')
        .create(
          body: {
            'email': email,
            'password': password,
            'passwordConfirm': passwordConfirm,
          },
        );
  }

  Future<void> createAlbum(String name) async {
    var id = _pb.authStore.record!.id;
    await _pb.collection('albums').create(body: {'name': name, 'owner': id});
  }

  Future<void> renameAlbum(String id, String name) async {
    await _pb.collection('albums').update(id, body: {'name': name});
  }

  Future<void> deleteAlbum(String id) async {
    final album = await _pb.collection('albums').getOne(id);
    final photos = album.getListValue<String>('photos');
    for (var photo in photos) {
      await deletePhotoFromAlbum(id, photo);
      logger.d('删除照片: $photo');
    }
    await _pb.collection('albums').delete(id);
  }

  Future<List<RecordModel>> fetchAlbums() async {
    return await _pb.collection('albums').getFullList();
  }

  Future<void> createPhotoToAlbum(String? albumId, PlatformFile file) async {
    final userID = _pb.authStore.record!.id;

    // 开始上传
    isUploading.value = true;
    uploadProgress.value = 0.0;
    uploadingFiles.add(file.name);
    uploadStatus.value = '准备上传: ${file.name}';

    try {
      logger.d(file);

      // 更新上传状态
      uploadProgress.value = 0.2;
      uploadStatus.value = '读取文件: ${file.name}';

      // 生成文件hash
      final fd = File(file.path!);
      final fstream = fd.openRead();
      final hash = await sha512.bind(fstream).first;
      logger.d('hash: $hash');

      final f = http.MultipartFile(
        'content',
        file.readStream!,
        file.size,
        filename: file.name,
      );

      // 更新上传状态
      uploadProgress.value = 0.5;
      uploadStatus.value = '上传中: ${file.name}';

      final result = await _pb
          .collection('photos')
          .create(
            body: {
              'name': file.name,
              'owner': userID,
              'size': file.size,
              'hash': hash.toString(),
            },
            files: [f],
          );

      await _pb
          .collection('albums')
          .update(albumId!, body: {'photos+': result.id});

      // 上传完成
      uploadProgress.value = 1.0;
      uploadStatus.value = '上传完成: ${file.name}';

      // 延迟一下让用户看到完成状态
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      uploadStatus.value = '上传失败: ${file.name}';
      logger.e('上传失败: $e');
      rethrow;
    } finally {
      // 清除上传状态
      uploadingFiles.remove(file.name);
      if (uploadingFiles.isEmpty) {
        isUploading.value = false;
        uploadProgress.value = 0.0;
        uploadStatus.value = '';
      }
    }
  }

  Future<List<Map<String, Object>>> fetchAlbumPhotos(String id) async {
    final filter = 'albums.id ?= "$id"';
    logger.d('filter: $filter');

    final testAlbum = await _pb
        .collection('albums')
        .getOne(id, expand: "photos");
    final photos = testAlbum.get<List<RecordModel>>('expand.photos');

    // final photos = await _pb.collection('photos').getFullList(filter: filter);
    final result = photos.map((photo) {
      return {
        'id': photo.id,
        'name': photo.get<String>('name'),
        // 'hash': photo.get<String>('hash'),
        'preview_url': _pb.files.getURL(
          photo,
          photo.get<String>('content'),
          thumb: '200x200',
        ),
        'url': _pb.files.getURL(photo, photo.get<String>('content')),
      };
    }).toList();
    return result;
  }

  Future<void> deletePhotoFromAlbum(String albumID, String photoID) async {
    await _pb.collection('albums').update(albumID, body: {'photos-': photoID});
    try {
      await _pb
          .collection('albums')
          .getFirstListItem('photos.id ?= "$photoID"');
    } catch (e) {
      // TODO: 删除图片变成delay 30天 删除
      await _pb.collection('photos').delete(photoID);
    }
  }
}
