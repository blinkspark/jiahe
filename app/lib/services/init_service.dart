import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class InitService extends GetxService {
  final Logger logger = Get.put(
    Logger(level: Level.all, printer: PrettyPrinter(noBoxingByDefault: true)),
  );
  late final GetStorage storage;
  late final AsyncAuthStore authStore;
  late final PocketBase pb;

  Future<InitService> init() async {
    await dotenv.load();
    await GetStorage.init();
    storage = GetStorage();
    authStore = Get.put(
      AsyncAuthStore(
        save: (String data) async => storage.write('pb_auth', data),
        initial: storage.read<String>('pb_auth'),
      ),
    );
    pb = Get.put(PocketBase(dotenv.get('BASE_URL'), authStore: authStore));

    return this;
  }
}
