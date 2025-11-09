import 'package:app/components/create_album_dialog.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AlbumPage extends StatelessWidget {
  final appState = Get.find<AppStateController>();
  final logger = Get.find<Logger>();
  AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    appState.fetchAlbums();
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
        child: Obx(
          () => GridView.builder(
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
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Center(child: Text(album.get<String>('name'))),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
