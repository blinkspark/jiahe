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
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
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
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(title: Text("聊天"), onTap: () {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
