import 'package:app/pages/AlbumPage.dart';
import 'package:app/pages/LoginPage.dart';
import 'package:app/pages/MainPage.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load();
  Get.lazyPut(() => AppStateController());
  Get.lazyPut(() => Logger(level: Level.debug));
  runApp(MainApp());
}

Logger newLogger() {
  return Logger(level: Level.debug);
}

class MainApp extends StatelessWidget {
  final controller = Get.find<AppStateController>();
  final logger = Get.find<Logger>();

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: _buildTheme(Brightness.light, Colors.blue),
      darkTheme: _buildTheme(Brightness.dark, Colors.blue),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MainPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/album', page: () => AlbumPage()),
      ],
    );
  }

  ThemeData _buildTheme(Brightness brightness, MaterialColor seedColor) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: seedColor,
      ),
      appBarTheme: AppBarTheme(elevation: 4),
    );
    return base.copyWith(
      textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme),
    );
  }
}
