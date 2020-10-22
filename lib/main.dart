import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'future_image.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Photos', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State createState() => HomePageState();
}

class HomePageState extends State {
  AssetPathEntity path;
  int pageSize = 20;
  List<AssetEntity> assetList = [];

  @override
  void initState() {
    super.initState();
    PhotoManager.requestPermission().then((success) async {
      if (success) {
        final pathList = await PhotoManager.getAssetPathList(onlyAll: true);
        path = pathList[0];
        getAssetList();
      }
    });
  }

  void getAssetList() async {
    assetList = await path.getAssetListPaged(0, pageSize);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photos')),
      body: GridView.builder(
        itemCount: assetList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemBuilder: (context, i) {
          return LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return InkWell(
              onLongPress: () => print('onLongPress'),
              onTap: () => open(context, i),
              child: Image(
                width: width,
                height: width,
                fit: BoxFit.cover,
                image: FutureMemoryImage(assetList[i].thumbData),
              ),
            );
          });
        },
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Gallery(items: assetList, index: index),
      ),
    );
  }
}

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
