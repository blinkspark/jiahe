import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

class StateController extends GetxController {
  var count = 0.obs;
  final _pb = PocketBase('http://127.0.0.1:8090/');

  StateController() {
    _pb.authStore.onChange.listen((data) {
    });
  }

  void increment() {
    count++;
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _pb
          .collection('users')
          .authWithPassword(email, password);
      print('Login successful: $user');
    } catch (e) {
      print('Login failed: $e');
    }
  }
}
