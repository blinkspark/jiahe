import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class MePage extends StatelessWidget {
  final appState = Get.find<AppStateController>();

  MePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.isLogin.value
                                  ? appState.username.value
                                  : "未登录",
                              style: Get.theme.textTheme.titleMedium,
                            ),
                            Text(
                              appState.isLogin.value ? "已登录" : "请登录以访问更多功能",
                              style: Get.theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (!appState.isLogin.value)
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
                                    child: Text('确定'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (res == true) appState.logout();
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
                      ListTile(
                        title: Text('亮主题'),
                        onTap: () {
                          Get.changeThemeMode(ThemeMode.light);
                        },
                      ),
                      ListTile(
                        title: Text('暗主题'),
                        onTap: () {
                          Get.changeThemeMode(ThemeMode.dark);
                        },
                      ),
                      ListTile(
                        title: Text('跟随系统'),
                        onTap: () {
                          Get.changeThemeMode(ThemeMode.system);
                        },
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
