import 'package:app/components/create_album_dialog.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AlbumsPage extends StatelessWidget {
  final appState = Get.find<AppStateController>();
  final logger = Get.find<Logger>();
  final isFetching = false.obs;
  AlbumsPage({super.key});

  Future<void> fetchAlbums() async {
    isFetching.value = true;
    try {
      await appState.fetchAlbums();
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '获取相册失败');
    } finally {
      isFetching.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchAlbums();
    return Scaffold(
      appBar: AppBar(
        title: Text('相册'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.dialog(CreateAlbumDialog());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Obx(() {
          if (isFetching.value) {
            return Center(child: CircularProgressIndicator());
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: appState.albums.length,
              itemBuilder: (context, index) {
                final album = appState.albums[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed('/album/${album.get<String>('id')}');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Center(child: Text(album.get<String>('name'))),
                  ),
                );
              },
            );
          }
        }),
      ),
    );
  }
}
