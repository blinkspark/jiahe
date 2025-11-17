import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ShareAlmubPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  final followers = <Map<String, dynamic>>[].obs;

  ShareAlmubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final albumID = Get.parameters['id']!;
    logger.d("albumID: $albumID");
    fetchFollowers(albumID);

    return Scaffold(
      appBar: AppBar(title: const Text("Share Almub")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final follower = followers[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    title: Text(follower['name']),
                    trailing: ElevatedButton(
                      onPressed: follower['isShared']
                          ? null
                          : () async {
                              logger.d("TODO: Share with ${follower['name']}");
                              await Get.dialog(ShareAlmubDialog());
                            },
                      child: Text('分享'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> fetchFollowers(String albumID) async {
    try {
      final flrs = await appState.fetchFollowers();
      followers.value = await flrs.map((e) async {
        logger.d('e: $e');
        final isShared = await appState.isShared(e['id']);
        logger.d('isShared: $isShared');
        return {...e, 'isShared': isShared};
      }).wait;
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '获取关注者失败');
    }
  }
}

class ShareAlmubDialog extends StatelessWidget {
  const ShareAlmubDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("TODO: Share Almub Dialog");
  }
}
