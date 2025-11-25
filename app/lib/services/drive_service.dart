import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DriveService {
  late final PocketBase pb;
  late final Logger logger;
  DriveService({required this.pb, required this.logger});

  Future<void> createDrive() async {
    await pb.collection('drives').create(body: {'name': 'Drive', 'owner': ''});
  }
}
