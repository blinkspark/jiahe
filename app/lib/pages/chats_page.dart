import 'package:app/controllers/chats_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ChatsPage extends StatelessWidget {
  final Logger logger = Get.find();
  final ChatsController chatsController = Get.put(ChatsController());
  ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("聊天"), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: BeveledRectangleBorder(),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Obx(
                  () => SegmentedButton(
                    segments: [
                      ButtonSegment(value: "all", label: Text("全部")),
                      ButtonSegment(value: "friends", label: Text("好友")),
                      ButtonSegment(value: "groups", label: Text("群组")),
                      ButtonSegment(value: "ai", label: Text("AI")),
                    ],
                    onSelectionChanged: (value) {
                      chatsController.changeFilter(value.first);
                    },
                    selected: {chatsController.filter.value},
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: chatsController.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = chatsController.conversations[index];
                  final avatar = conversation['avatar'] as String;
                  if (avatar.isNotEmpty) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(avatar),
                      ),
                    );
                  } else {
                    return ListTile(
                      leading: CircleAvatar(child: Text(conversation['id'][0])),
                      title: Text(conversation['id']),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
