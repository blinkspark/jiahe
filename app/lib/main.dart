import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final controller = Get.put(StateController());

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();
    return GetMaterialApp(
      theme: _buildTheme(Brightness.light, Colors.blue),
      darkTheme: _buildTheme(Brightness.dark, Colors.blue),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => Scaffold(
            appBar: AppBar(
              title: Text('登录'),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '欢迎登录',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '用户名',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    controller: email,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      controller.login(email.text, password.text);
                      // 这里可以添加登录逻辑
                      // Get.snackbar('提示', '登录功能待实现');
                    },
                    child: Text('登录'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // 这里可以添加忘记密码逻辑
                      Get.snackbar('提示', '忘记密码功能待实现');
                    },
                    child: Text('忘记密码？'),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('还没有账号？'),
                      TextButton(
                        onPressed: () {
                          // 这里可以添加注册逻辑
                          Get.snackbar('提示', '注册功能待实现');
                        },
                        child: Text('立即注册'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
