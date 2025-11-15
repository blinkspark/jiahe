import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AddFriendDialog extends StatelessWidget {
  final AppStateController appState;
  final Logger logger;
  final VoidCallback onFollowAdded;
  final searchController = TextEditingController();
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;

  AddFriendDialog({
    super.key,
    required this.appState,
    required this.logger,
    required this.onFollowAdded,
  });

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      searchResults.value = await appState.searchUsers(query);
    } catch (e) {
      logger.e('搜索用户失败: $e');
      Get.snackbar('失败', '搜索用户失败');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> addFriend(String userId, String userName) async {
    try {
      await appState.addFollow(userId);
      Get.back(); // 关闭对话框
      Get.snackbar('成功', '已关注 $userName');
      onFollowAdded(); // 刷新关注列表
    } catch (e) {
      logger.e('关注失败: $e');
      Get.snackbar('失败', '关注失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        children: [
          Icon(Icons.person_add, color: Get.theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('添加朋友'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 搜索框
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '搜索用户名或邮箱',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Get.theme.colorScheme.surface,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: searchUsers,
            ),
            const SizedBox(height: 16),

            // 搜索结果
            Obx(() {
              if (isSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }

              if (searchController.text.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('请输入用户名或邮箱进行搜索'),
                );
              }

              if (searchResults.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('未找到相关用户'),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final user = searchResults[index];
                    final isFollowed = user['isFollowed'] as bool;
                    logger.d(user);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['name'][0].toString().toUpperCase()),
                        ),
                        title: Text(user['name']),
                        // subtitle: Text(user['email']),
                        trailing: ElevatedButton(
                          onPressed: isFollowed
                              ? null
                              : () => addFriend(user['id'], user['name']),
                          child: user['isFollowed'] as bool
                              ? const Text('已关注')
                              : const Text('关注'),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
      ],
    );
  }
}
