import 'package:app/state.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewPage extends StatefulWidget {
  final RxList<Map<String, Object>> photos;
  late final PageController pageController;
  final int index;

  PhotoViewPage({super.key, required this.photos, this.index = 0}) {
    pageController = PageController(initialPage: index);
  }

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  final appState = Get.find<AppStateController>();

  final logger = Get.find<Logger>();

  final name = ''.obs;

  final index = 0.obs;

  final photoControllers = <int, PhotoViewController>{};

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(handleKeys);
    index.value = widget.index;
    super.initState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(handleKeys);
    super.dispose();
  }

  PhotoViewController getPhotoController(int index) {
    photoControllers[index] ??= PhotoViewController();
    return photoControllers[index]!;
  }

  bool handleKeys(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.pageController.previousPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.pageController.nextPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final page = (widget.pageController.page ?? 0).toInt();
      final photoController = getPhotoController(page);
      photoController.scale = photoController.scale! * 1.1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final page = (widget.pageController.page ?? 0).toInt();
      final photoController = getPhotoController(page);
      photoController.scale = photoController.scale! * 0.9;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Get.back();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(title: Text(name.value)),
        body: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.photos.length,
          pageController: widget.pageController,
          builder: (context, index) => PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              widget.photos[index]['url'].toString(),
            ),
            controller: getPhotoController(index),
            filterQuality: FilterQuality.medium,
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.photos[index]['id'].toString(),
            ),
          ),
        ),
      ),
    );
  }
}
