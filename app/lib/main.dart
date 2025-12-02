import 'package:app/pages/album_view_page.dart';
import 'package:app/pages/albums_page.dart';
import 'package:app/pages/follows_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/share_almub_page.dart';
import 'package:app/services/init_service.dart';
import 'package:app/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/web.dart';
import 'package:media_kit/media_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  await Get.putAsync(() => InitService().init());
  Get.put(AppStateController());
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final controller = Get.find<AppStateController>();
  final logger = Get.find<Logger>();

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: _buildTheme(Brightness.light, Colors.cyan),
      darkTheme: _buildTheme(Brightness.dark, Colors.cyan),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/albums', page: () => AlbumsPage()),
        GetPage(name: '/album', page: () => AlbumViewPage()),
        GetPage(name: '/follows', page: () => FollowsPage()),
        GetPage(name: '/share_album', page: () => ShareAlbumPage()),
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
