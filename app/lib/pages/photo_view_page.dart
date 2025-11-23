import 'package:app/state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewPage extends StatefulWidget {
  final RxList<Map<String, dynamic>> photos;
  final int index;

  const PhotoViewPage({super.key, required this.photos, this.index = 0});
  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  final appState = Get.find<AppStateController>();

  final logger = Get.find<Logger>();

  final name = ''.obs;

  final index = 0.obs;

  final photoControllers = <int, PhotoViewController>{};

  late final PageController pageController;
  late PhotoViewController photoController;

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(handleKeys);
    pageController = PageController(initialPage: widget.index);
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
      final page = (pageController.page ?? 0).toInt();
      final photoController = getPhotoController(page);
      // reset position
      photoController.position = Offset.zero;

      pageController.previousPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final page = (pageController.page ?? 0).toInt();
      final photoController = getPhotoController(page);
      // reset position
      photoController.position = Offset.zero;

      pageController.nextPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final page = (pageController.page ?? 0).toInt();
      final photoController = getPhotoController(page);
      photoController.scale = photoController.scale! * 1.1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final page = (pageController.page ?? 0).toInt();
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
          backgroundDecoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
          ),
          itemCount: widget.photos.length,
          pageController: pageController,
          loadingBuilder: (context, event) {
            return Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : (event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!),
                ),
              ),
            );
          },
          builder: (context, index) => PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
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
