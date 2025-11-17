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
      appBar: AppBar(title: const Text("分享相册"), centerTitle: true),
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
                    trailing: follower['isShared']
                        ? ElevatedButton(
                            onPressed: () async {
                              await appState.unshareAlbum(
                                albumID,
                                follower['from'],
                              );
                              await fetchFollowers(albumID);
                            },
                            child: Text('取消分享'),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              await Get.dialog(
                                ShareAlmubDialog(
                                  albumID: albumID,
                                  followerID: follower['from'],
                                ),
                              );
                              await fetchFollowers(albumID);
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
        final isShared = await appState.isShared(albumID, e['from']);
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
  final String albumID;
  final String followerID;
  ShareAlmubDialog({
    super.key,
    required this.albumID,
    required this.followerID,
  });
  final isWrite = false.obs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('分享'),
      content: Row(
        children: [
          const Text('赋予写权限'),
          Obx(
            () => Switch(
              value: isWrite.value,
              onChanged: (v) => isWrite.value = v,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        TextButton(
          onPressed: () async {
            final AppStateController appState = Get.find();
            await appState.shareAlbum(albumID, followerID, isWrite.value);
            Get.back();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
