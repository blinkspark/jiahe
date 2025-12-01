import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final rememberMe = false.obs;
  final email = ''.obs;
  final store = Get.find<GetStorage>();

  @override
  void onInit() {
    super.onInit();
    rememberMe.value = store.read('rememberMe') ?? false;
    email.value = store.read('email') ?? '';
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    store.write('rememberMe', rememberMe.value);
    if (rememberMe.value == false) {
      setEmail('');
    }
  }

  void setEmail(String value) {
    email.value = value;
    store.write('email', value);
  }
}
