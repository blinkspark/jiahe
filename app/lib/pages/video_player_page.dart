import 'package:app/controllers/video_player_controller.dart';
import 'package:app/services/drive_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  final Player player = Player();
  late final VideoController mkController = VideoController(player);
  late final RxInt index;
  late final RxList<Map<String, dynamic>> videos;
  final loading = true.obs;

  @override
  void initState() {
    super.initState();
    index = widget.index.obs;
    videos = widget.videos.obs;
    playerInit();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> playerInit() async {
    loading.value = true;
    try {
      videos.value = await videos.map((e) async {
        e['url'] = await driveService.getDownloadUrl(e['id']);
        return e;
      }).wait;
      await player.open(Media(videos[index.value]['url']));
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
        backgroundColor: Get.isDarkMode
            ? Get.theme.colorScheme.surface
            : Get.theme.colorScheme.inverseSurface,
        foregroundColor: Get.isDarkMode
            ? Get.theme.colorScheme.onSurface
            : Get.theme.colorScheme.onInverseSurface,
        centerTitle: true,
      ),
      body: Obx(() {
        return loading.value
            ? const Center(child: CircularProgressIndicator())
            : Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final volume = player.state.volume;
                    player.setVolume(volume + -event.scrollDelta.dy / 100);
                  }
                },
                child: Video(
                  controller: mkController,
                  filterQuality: FilterQuality.medium,
                ),
              );
      }),
    );
  }
}
