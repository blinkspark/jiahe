import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatService extends GetxService {
  final Logger logger = Get.find();
  final PocketBase pb = Get.find();

  Future<List<Map<String, dynamic>>> getConversations() async {
    final chats = await pb.collection('conversations').getFullList();
    return chats.map((e) => e.data).toList();
  }
}
