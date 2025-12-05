import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatService extends GetxService {
  final Logger logger = Get.find();
  final PocketBase pb = Get.find();
}
