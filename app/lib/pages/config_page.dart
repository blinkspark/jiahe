import 'package:app/controllers/config_controller.dart';
import 'package:app/controllers/user_controller.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';

class ConfigPage extends StatelessWidget {
  final logger = Get.find<Logger>();
  final appState = Get.find<AppStateController>();
  final configController = Get.put(ConfigController());
  final userController = Get.put(UserController());

  ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d(configController.themeMode.value);
    return Scaffold(
      appBar: AppBar(title: Text("我的"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            // 用户信息卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(
                  () => Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Get.theme.colorScheme.primary
                            .withValues(alpha: 0.75),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Get.theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userController.isLogin.value
                                  ? userController.username.value
                                  : "未登录",
                              style: Get.theme.textTheme.titleMedium,
                            ),
                            Text(
                              userController.isLogin.value
                                  ? "已登录"
                                  : "请登录以访问更多功能",
                              style: Get.theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (!userController.isLogin.value)
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed('/login');
                          },
                          child: Text('登录'),
                        )
                      else
                        OutlinedButton(
                          onPressed: () async {
                            final res = await Get.dialog<bool>(
                              AlertDialog(
                                title: Text('提示'),
                                content: Text('确定要注销吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back(result: false);
                                    },
                                    child: Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back(result: true);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    child: Text('确定'),
                                  ),
                                ],
                              ),
                            );
                            if (res == true) userController.logout();
                          },
                          child: Text('注销'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // 设置卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.people,
                      color: Get.theme.colorScheme.primary,
                    ),
                    title: Text('关注'),
                    subtitle: Text('管理您的关注列表'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Get.toNamed('/follows');
                    },
                  ),
                  Divider(height: 1),
                  ExpansionTile(
                    leading: Icon(
                      Icons.palette,
                      color: Get.theme.colorScheme.primary,
                    ),
                    title: Text('主题模式'),
                    subtitle: Text('选择应用主题'),
                    children: [
                      Obx(
                        () => ListTile(
                          leading: Icon(
                            Icons.brightness_7,
                            color: Get.theme.colorScheme.primary,
                          ),
                          title: Text('亮主题'),
                          selected:
                              configController.themeMode.value ==
                              ThemeMode.light,
                          onTap: () {
                            configController.setThemeMode(ThemeMode.light);
                          },
                        ),
                      ),
                      Obx(
                        () => ListTile(
                          leading: Icon(
                            Icons.brightness_4,
                            color: Get.theme.colorScheme.primary,
                          ),
                          title: Text('暗主题'),
                          selected:
                              configController.themeMode.value ==
                              ThemeMode.dark,
                          onTap: () {
                            configController.setThemeMode(ThemeMode.dark);
                          },
                        ),
                      ),
                      Obx(
                        () => ListTile(
                          leading: Icon(
                            Icons.brightness_auto,
                            color: Get.theme.colorScheme.primary,
                          ),
                          title: Text('跟随系统'),
                          selected:
                              configController.themeMode.value ==
                              ThemeMode.system,
                          onTap: () {
                            configController.setThemeMode(ThemeMode.system);
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.cleaning_services,
                      color: Get.theme.colorScheme.primary,
                    ),
                    title: Text('清除缓存'),
                    subtitle: Text('清除应用缓存数据'),
                    onTap: () async {
                      try {
                        await DefaultCacheManager().emptyCache();
                        Get.snackbar('提示', '清除缓存成功');
                      } catch (e) {
                        Get.snackbar('错误', e.toString());
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
