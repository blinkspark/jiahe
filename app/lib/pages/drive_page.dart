import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class DrivePage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();

  DrivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DrivePage"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () async {
              Get.dialog(DriveDebugDialog());
            },
          ),
        ],
      ),
      body: Center(child: Text("DrivePage")),
    );
  }
}

class DriveDebugDialog extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();

  DriveDebugDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("DriveDebugDialog"),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              // TODO: await appState.createDrive();
              Get.back();
              Get.snackbar("Success", "Drive created");
            } catch (e) {
              logger.e(e);
              Get.back();
              Get.snackbar(
                "Error",
                e.toString(),
                borderColor: Get.theme.colorScheme.error,
                borderWidth: 2,
              );
            }
          },
          child: Text("Create Drive"),
        ),
        TextButton(
          child: Text("Close"),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }
}
