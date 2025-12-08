import 'package:app/services/chat_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ChatsController extends GetxController {
  final Logger logger = Get.find();
  final ChatService chatService = Get.put(ChatService());
  final filter = "all".obs;

  final conversations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  void changeFilter(String value) {
    filter.value = value;
  }

  void fetchConversations() async {
    final res = await chatService.getConversations();
    conversations.value = res;
  }
}
