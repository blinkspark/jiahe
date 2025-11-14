import 'package:app/state.dart';
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

  PhotoViewPage({super.key, required this.photos, index = 0}) {
    this.index.value = index;
    pageController = PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(title: Text(name.value)),
        body: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: photos.length,
          pageController: pageController,
          builder: (context, index) => PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(photos[index]['url'].toString()),
            filterQuality: FilterQuality.medium,
            heroAttributes: PhotoViewHeroAttributes(
              tag: photos[index]['id'].toString(),
            ),
          ),
        ),
      ),
    );
  }
}
