import 'package:app/state.dart';
import 'package:app/components/add_friend_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class FollowsPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  final follows = <Map<String, dynamic>>[].obs;
  final followers = <Map<String, dynamic>>[].obs;

  FollowsPage({super.key});

  Future<void> fetchFollows() async {
    logger.d('开始获取关注列表');
    try {
      follows.value = await appState.fetchFollows();
      logger.d('关注列表: $follows');
    } catch (e) {
      logger.e('获取关注列表失败: $e');
    }
  }

  Future<void> fetchFollowers() async {
    logger.d('开始获取关注者列表');
    try {
      followers.value = await appState.fetchFollowers();
      logger.d('关注者列表: $followers');
    } catch (e) {
      logger.e('获取关注者列表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchFollows();
    fetchFollowers();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('关注'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                _showAddFriendDialog(context);
              },
              icon: const Icon(Icons.add),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: '我关注的'),
              Tab(text: '关注我的'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FollowsList(
              users: follows,
              onRefresh: fetchFollows,
              emptyText: '还没有关注任何人',
            ),
            _FollowsList(
              users: followers,
              onRefresh: fetchFollowers,
              emptyText: '还没有人关注你',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddFriendDialog(
          appState: appState,
          logger: logger,
          onFollowAdded: () {
            fetchFollows(); // 刷新关注列表
          },
        );
      },
    );
  }
}

class _FollowsList extends StatelessWidget {
  final RxList<Map<String, dynamic>> users;
  final Future<void> Function() onRefresh;
  final String emptyText;

  const _FollowsList({
    required this.users,
    required this.onRefresh,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (users.isEmpty) {
        // 首次加载时显示加载状态
        if (users.runtimeType.toString().contains('RxList')) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRefresh,
                    child: const Text('刷新'),
                  ),
                ],
              ),
            ),
          );
        }
      }
      
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(
              user: user,
              onRefresh: onRefresh,
            );
          },
        ),
      );
    });
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Future<void> Function() onRefresh;

  const _UserCard({
    required this.user,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final AppStateController appState = Get.find();
    final Logger logger = Get.find();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            user['name']?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['name'] ?? '未知用户',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          user['email'] ?? '',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'unfollow') {
              try {
                await appState.deleteFollow(user['id']);
                await onRefresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已取消关注')),
                );
              } catch (e) {
                logger.e('取消关注失败: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('操作失败: $e')),
                );
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'unfollow',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 16),
                  SizedBox(width: 8),
                  Text('取消关注'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
