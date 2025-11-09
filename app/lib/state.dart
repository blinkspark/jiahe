import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

class AppStateController extends GetxController {
  final isLogin = false.obs;
  final _box = GetStorage();
  late final AsyncAuthStore _authStore;
  late final PocketBase _pb;
  final Logger logger = Get.find();
  final RxList<RecordModel> albums = <RecordModel>[].obs;
  AppStateController() {
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

  Future<void> deleteAlbum(String id) async {
    await _pb.collection('albums').delete(id);
  }

  Future<void> fetchAlbums() async {
    albums.value = await _pb.collection('albums').getFullList();
  }

  Future<void> addFileToAlbum(String? albumId, PlatformFile file) async {
    await _pb
        .collection('photos')
        .create(
          body: {'name': file.name},
          files: [
            http.MultipartFile.fromBytes(
              'content',
              file.bytes!,
              filename: file.name,
            ),
          ],
        );
  }
}
