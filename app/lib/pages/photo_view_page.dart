import 'package:app/state.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewPage extends StatelessWidget {
  final appState = Get.find<AppStateController>();
  final logger = Get.find<Logger>();
  final RxList<Map<String, Object>> photos;
  final name = ''.obs;
  final index = 0.obs;
  late final PageController pageController;
  final photoControllers = <int, PhotoViewController>{};

  PhotoViewPage({super.key, required this.photos, index = 0}) {
    this.index.value = index;
    pageController = PageController(initialPage: index);
  }

  PhotoViewController getPhotoController(int index) {
    photoControllers[index] ??= PhotoViewController();
    return photoControllers[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (value) {
          if (value is! KeyDownEvent) {
            return;
          }
          if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
            pageController.previousPage(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          } else if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
            pageController.nextPage(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          } else if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
            final page = (pageController.page ?? 0).toInt();
            final photoController = getPhotoController(page);
            photoController.scale = photoController.scale! * 1.1;
          } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
            final page = (pageController.page ?? 0).toInt();
            final photoController = getPhotoController(page);
            photoController.scale = photoController.scale! * 0.9;
          } else if (value.logicalKey == LogicalKeyboardKey.escape) {
            Get.back();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(name.value)),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: photos.length,
            pageController: pageController,
            builder: (context, index) => PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(photos[index]['url'].toString()),
              controller: getPhotoController(index),
              filterQuality: FilterQuality.medium,
              heroAttributes: PhotoViewHeroAttributes(
                tag: photos[index]['id'].toString(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
