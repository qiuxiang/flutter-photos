import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'future_image.dart';

class Gallery extends StatefulWidget {
  Gallery({@required this.items, this.index})
      : pageController = PageController(initialPage: index);

  final int index;
  final PageController pageController;
  final List<AssetEntity> items;

  @override
  State createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(children: [
          PhotoViewGallery.builder(
            builder: (context, i) {
              final item = widget.items[i];
              return PhotoViewGalleryPageOptions(
                imageProvider: FutureFileImage(item.file),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 4,
              );
            },
            itemCount: widget.items.length,
            pageController: widget.pageController,
          ),
          SizedBox(
            height: kToolbarHeight + 24,
            child: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
          ),
        ]),
      ),
    );
  }
}
