import 'dart:io';

import 'package:app/pages/photo_view_page.dart';
import 'package:app/state.dart';
import 'package:app/components/photo_grid.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AlbumViewPage extends StatelessWidget {
  final AppStateController appState = Get.find();
  final Logger logger = Get.find();
  final photos = <Map<String, Object>>[].obs;
  AlbumViewPage({super.key});

  Future<void> getPhotos(String albumId) async {
    try {
      photos.value = await appState.fetchAlbumPhotos(albumId);
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '获取相册照片失败');
    }
  }

  void _showPhotoMenu(BuildContext context, int index) {
    final photo = photos[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许部分滚动
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

                // 照片预览
                Container(
                  width: double.infinity,
                  height: 150, // 减小高度
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Get.theme.colorScheme.surfaceContainerLow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photo['preview_url'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Get.theme.colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 菜单项
                _buildMenuItem(
                  context: context,
                  icon: Icons.delete_outline,
                  title: '删除照片',
                  onTap: () async {
                    Get.back();
                    try {
                      await _deletePhoto(index, context);
                    } catch (e) {
                      logger.e(e);
                      Get.snackbar('错误', '删除照片失败');
                    }
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.share_outlined,
                  title: '分享照片',
                  onTap: () async {
                    Get.back();
                    await _sharePhoto(index);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.download_outlined,
                  title: '保存到本地',
                  onTap: () async {
                    Get.back();
                    await _savePhotoLocally(index);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: '查看详情',
                  onTap: () {
                    Get.back();
                    _showPhotoDetails(context, index);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: '编辑照片',
                  onTap: () async {
                    Get.back();
                    await _editPhoto(index);
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

  Future<void> _deletePhoto(int index, BuildContext context) async {
    final photo = photos[index];
    final theme = Theme.of(context);
    try {
      // 这里应该调用删除照片的API
      logger.d('删除照片: ${photo['id']}');

      // 确认删除对话框
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            '确认删除',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            '确定要删除这张照片吗？此操作无法撤销。',
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
              child: Text(
                '删除',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // 执行删除操作
        await appState.removePhoto(
          Get.parameters['id']!,
          photo['id'].toString(),
        );
        await getPhotos(Get.parameters['id']!);
        Get.snackbar('成功', '照片已删除');
      }
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '删除照片失败');
    }
  }

  Future<void> _sharePhoto(int index) async {
    try {
      // TODO: 这里应该实现分享功能
      logger.d('分享照片: ${photos[index]['id']}');
      Get.snackbar('提示', '分享功能开发中');
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '分享照片失败');
    }
  }

  Future<void> _savePhotoLocally(int index) async {
    try {
      // 这里应该实现保存到本地的功能
      logger.d('保存照片到本地: ${photos[index]['id']}');
      final path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        final file = File('$path/${photos[index]['name']}');
        await Dio().download(photos[index]['url'].toString(), file.path);
        logger.d('照片已保存到本地: $path');
        Get.snackbar('成功', '照片已保存到本地');
      }
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '保存照片失败');
    }
  }

  void _showPhotoDetails(BuildContext context, int index) {
    final photo = photos[index];
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '照片详情',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          backgroundColor: theme.colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '照片ID: ${photo['id']}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Text(
                '文件名: ${photo['name'] ?? '未知'}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Text(
                '创建时间: ${photo['created_at'] ?? '未知'}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              if (photo['size'] != null) ...[
                SizedBox(height: 8),
                Text(
                  '文件大小: ${_formatFileSize(photo['size'] as int)}',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ],
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

  Future<void> _editPhoto(int index) async {
    try {
      // 这里应该实现编辑功能
      logger.d('编辑照片: ${photos[index]['id']}');
      Get.snackbar('提示', '编辑功能开发中');
    } catch (e) {
      logger.e(e);
      Get.snackbar('错误', '编辑照片失败');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    logger.d(Get.parameters);
    final albumId = Get.parameters['id'];
    final name = Get.parameters['name'];
    getPhotos(albumId!);
    return Scaffold(
      appBar: AppBar(
        title: Text(name!),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              // 如果正在上传，不允许重复上传
              if (appState.isUploading.value) {
                Get.snackbar('提示', '正在上传中，请稍候');
                return;
              }

              var res = await FilePicker.platform.pickFiles(
                withReadStream: true,
                allowMultiple: true,
              );

              if (res != null && res.files.isNotEmpty) {
                // 串行上传文件以显示进度
                for (var file in res.files) {
                  try {
                    await appState.createPhotoToAlbum(albumId, file);
                    // 上传成功后刷新照片列表
                    await getPhotos(albumId);
                  } catch (e) {
                    logger.e(e);
                    Get.snackbar('错误', '上传照片失败: ${file.name}');
                  }
                }
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Obx(
        () => Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              // 上传进度显示
              if (appState.isUploading.value) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: appState.uploadProgress.value,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              appState.uploadStatus.value,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: appState.uploadProgress.value,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      if (appState.uploadingFiles.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          '队列中的文件: ${appState.uploadingFiles.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
              // 照片网格
              Expanded(
                child: PhotoGrid(
                  photos: photos,
                  onTap: (index) {
                    Get.to(PhotoViewPage(photos: photos, index: index));
                  },
                  onLongPress: (index) {
                    _showPhotoMenu(context, index);
                  },
                  logger: logger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
