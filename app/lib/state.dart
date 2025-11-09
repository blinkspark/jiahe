import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pocketbase/pocketbase.dart';

class AppStateController extends GetxController {
  final isLogin = false.obs;
  final _box = GetStorage();
  late final AsyncAuthStore _authStore;
  late final PocketBase _pb;

  AppStateController() {
    _authStore = AsyncAuthStore(
      save: (String data) async => _box.write('pb_auth', data),
      initial: _box.read<String>('pb_auth'),
    );
    _pb = PocketBase(dotenv.get('BASE_URL'), authStore: _authStore);
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
}
