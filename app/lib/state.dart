import 'package:get/get.dart';

class StateController extends GetxController {
  var count = 0.obs;

  void increment() {
    count++;
  }
}
