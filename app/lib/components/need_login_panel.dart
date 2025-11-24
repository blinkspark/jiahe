import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class NeedLoginPanel extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();

  NeedLoginPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('请先登录'),
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/login');
            },
            child: Text('登录'),
          ),
        ],
      ),
    );
  }
}
