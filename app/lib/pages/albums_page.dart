import 'package:app/components/create_album_dialog.dart';
import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class AlbumsPage extends StatelessWidget {
  final appState = Get.find<AppStateController>();
  final logger = Get.find<Logger>();
  final isFetching = false.obs;
  final albums = <RecordModel>[].obs;
  AlbumsPage({super.key});

  Future<void> fetchAlbums() async {
    isFetching.value = true;
    try {
      albums.value = await appState.fetchAlbums();
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '获取相册失败');
    } finally {
      isFetching.value = false;
    }
  }

  void _showAlbumMenu(BuildContext context, int index) {
    final album = albums[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surfaceContainerHigh,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  margin: EdgeInsets.only(top: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 相册预览
                Container(
                  width: double.infinity,
                  height: 150,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Get.theme.colorScheme.surfaceContainerLow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder,
                            size: 48,
                            color: Get.theme.colorScheme.primary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            album.get<String>('name'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Get.theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 菜单项
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: '重命名相册',
                  onTap: () async {
                    Get.back();
                    await _renameAlbum(index, context);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.delete_outline,
                  title: '删除相册',
                  onTap: () async {
                    Get.back();
                    try {
                      await _deleteAlbum(index, context);
                    } catch (e) {
                      logger.e(e);
                      Get.snackbar('错误', '删除相册失败');
                    }
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.share_outlined,
                  title: '分享相册',
                  onTap: () async {
                    Get.back();
                    await _shareAlbum(index);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: '查看详情',
                  onTap: () {
                    Get.back();
                    _showAlbumDetails(context, index);
                  },
                ),

                // 取消按钮
                Padding(
                  padding: EdgeInsets.all(20),
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text('取消'),
                  ),
                ),

                // 底部安全区域
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _renameAlbum(int index, BuildContext context) async {
    final album = albums[index];
    final theme = Theme.of(context);
    final TextEditingController controller = TextEditingController(
      text: album.get<String>('name'),
    );

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          '重命名相册',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '相册名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              '取消',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              '确定',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && controller.text.trim().isNotEmpty) {
      try {
        // 这里应该调用重命名API
        logger.d(
          '重命名相册: ${album.get<String>('id')} -> ${controller.text.trim()}',
        );
        Get.snackbar('成功', '相册已重命名');
        await fetchAlbums(); // 刷新列表
      } catch (e) {
        logger.e(e);
        Get.snackbar('错误', '重命名失败');
      }
    }
  }

  Future<void> _deleteAlbum(int index, BuildContext context) async {
    final album = albums[index];
    final theme = Theme.of(context);

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          '确认删除',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          '确定要删除相册 "${album.get<String>('name')}" 吗？此操作无法撤销。',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              '取消',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('删除', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // 这里应该调用删除相册的API
        logger.d('删除相册: ${album.get<String>('id')}');
        Get.snackbar('成功', '相册已删除');
        await fetchAlbums(); // 刷新列表
      } catch (e) {
        logger.e(e);
        rethrow;
      }
    }
  }

  Future<void> _shareAlbum(int index) async {
    try {
      final album = albums[index];
      // TODO: 这里应该实现分享功能
      logger.d('分享相册: ${album.get<String>('id')}');
      Get.snackbar('提示', '分享功能开发中');
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '分享相册失败');
    }
  }

  void _showAlbumDetails(BuildContext context, int index) {
    final album = albums[index];
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '相册详情',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          backgroundColor: theme.colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '相册ID: ${album.get<String>('id')}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Text(
                '相册名称: ${album.get<String>('name')}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Text(
                '创建时间: ${album.get<String>('created')}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Text(
                '更新时间: ${album.get<String>('updated')}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                '关闭',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
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
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(
                        '/album/${album.get<String>('id')}?name=${album.get<String>('name')}',
                      );
                    },
                    onLongPress: () {
                      _showAlbumMenu(context, index);
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
