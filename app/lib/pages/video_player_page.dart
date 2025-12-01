import 'package:app/controllers/video_player_controller.dart';
import 'package:app/services/drive_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart' as vp;

class VideoPlayerPage extends StatefulWidget {
  final List<Map<String, dynamic>> videos;
  final int index;
  const VideoPlayerPage({super.key, required this.videos, required this.index});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final VideoPlayerController controller = Get.put(VideoPlayerController());
  final DriveService driveService = Get.put(DriveService());

  final Logger logger = Get.find();
  late final vp.VideoPlayerController vpController;
  late final RxInt index;
  late final RxList<Map<String, dynamic>> videos;
  final loading = true.obs;

  @override
  void initState() {
    super.initState();
    index = widget.index.obs;
    videos = widget.videos.obs;
    logger.d(index.value);
    logger.d(videos.toJson());
    pinit();
  }

  Future<void> pinit() async {
    loading.value = true;
    try {
      videos.value = await videos.map((e) async {
        e['url'] = await driveService.getDownloadUrl(e['id']);
        return e;
      }).wait;
      vpController = vp.VideoPlayerController.networkUrl(
        Uri.parse(videos[index.value]['url']),
      );
      await vpController.initialize();
      vpController.play();
    } catch (e) {
      logger.e(e);
      Get.snackbar("Error", e.toString());
    } finally {
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(videos[index.value]['name']),
        centerTitle: true,
      ),
      body: Obx(() {
        return loading.value
            ? const Center(child: CircularProgressIndicator())
            : Center(child: vp.VideoPlayer(vpController));
      }),
    );
  }
}
