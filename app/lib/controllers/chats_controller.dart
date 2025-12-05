import 'package:app/services/chat_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ChatsController extends GetxController {
  final Logger logger = Get.find();
  final ChatService chatService = Get.put(ChatService());
  final filter = "all".obs;

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  void changeFilter(String value) {
    filter.value = value;
  }
}
