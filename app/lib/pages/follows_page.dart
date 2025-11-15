import 'package:app/state.dart';
import 'package:app/components/add_friend_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class FollowsPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  final follows = <Map<String, dynamic>>[].obs;

  FollowsPage({super.key});

  Future<void> fetchFollows() async {
    try {
      follows.value = await appState.fetchFollows();
      logger.d(follows);
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchFollows();
    return Scaffold(
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
      ),
      body: const Center(child: Text('关注列表')),
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
