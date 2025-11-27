import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class UserService extends GetxService {
  final Logger logger = Get.find();
  final PocketBase pb = Get.find();

  Future<String?> getUserID() async {
    return pb.authStore.record?.id;
  }

  Future<String?> getUserName() async {
    return pb.authStore.record?.getStringValue("name");
  }

  void onChange(void Function(AuthStoreEvent)? onData) {
    pb.authStore.onChange.listen(onData);
  }
}
