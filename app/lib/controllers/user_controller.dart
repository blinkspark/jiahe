import 'package:app/services/user_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class UserController extends GetxController {
  final logger = Get.find<Logger>();
  final userService = Get.put(UserService());

  final username = ''.obs;
  final isLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLogin.value = userService.getUserID() != null;
    username.value = userService.getUserName() ?? '';
    userService.onChange((event) {
      isLogin.value = event.record != null;
      username.value = event.record?.getStringValue('name') ?? '';
    });
  }

  void logout() {
    userService.logout();
  }
}
