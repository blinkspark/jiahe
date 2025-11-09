import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pocketbase/pocketbase.dart';

class StateController extends GetxController {
  final isLogin = false.obs;
  final _box = GetStorage();
  late final AsyncAuthStore _authStore;
  late final PocketBase _pb;

  StateController() {
    _authStore = AsyncAuthStore(
      save: (String data) async => _box.write('pb_auth', data),
      initial: _box.read<String>('pb_auth'),
    );
    _pb = PocketBase('http://127.0.0.1:8090', authStore: _authStore);
    _pb.authStore.onChange.listen((data) {
      isLogin.value = _pb.authStore.isValid;
    });
  }

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }
}
