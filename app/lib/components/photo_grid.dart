import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class PhotoGrid extends StatelessWidget {
  final RxList<Map<String, Object>> photos;
  final Function(int index)? onTap;
  final Function(int index)? onLongPress;
  final Logger? logger;
  final double maxCrossAxisExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.onTap,
    this.onLongPress,
    this.logger,
    this.maxCrossAxisExtent = 200,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.childAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final url = photos[index]['preview_url'] as Uri?;
          return Card(
            child: InkWell(
              onTap: () {
                onTap?.call(index);
              },
              onLongPress: () {
                onLongPress?.call(index);
              },
              child: Image.network(
                url!.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}