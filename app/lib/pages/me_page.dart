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
      appBar: AppBar(
        title: Text("我的"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息部分
            Obx(() => appState.isLogin.value
                ? _buildUserProfile(context)
                : _buildLoginPrompt(context)),
            const SizedBox(height: 20),
            // 设置部分
            _buildSettingsSection(context),
            const SizedBox(height: 20),
            // 操作部分
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.username.value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '已登录',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.account_circle, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              '未登录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/login'),
              icon: Icon(Icons.login),
              label: Text('登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设置',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.palette),
              title: Text('主题模式'),
              subtitle: Text('选择应用的主题'),
              trailing: PopupMenuButton<ThemeMode>(
                onSelected: (ThemeMode mode) {
                  Get.changeThemeMode(mode);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Text('亮主题'),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Text('暗主题'),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Text('跟随系统'),
                  ),
                ],
                child: Icon(Icons.more_vert),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.cleaning_services),
              title: Text('清除缓存'),
              subtitle: Text('清除应用缓存'),
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
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('关注'),
              onTap: () => Get.toNamed('/follows'),
            ),
            Obx(() => appState.isLogin.value
                ? ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('注销'),
                    onTap: () async {
                      final res = await Get.dialog<bool>(
                        AlertDialog(
                          title: Text('提示'),
                          content: Text('确定要注销吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: Text('确定'),
                            ),
                          ],
                        ),
                      );
                      if (res == true) appState.logout();
                    },
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
