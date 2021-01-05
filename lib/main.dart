import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'future_image.dart';
import 'gallery.dart';
import 'histogram.dart';

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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemBuilder: (context, i) {
          return LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return InkWell(
              onLongPress: () => open(context, assetList[i]),
              onTap: () => openGallery(context, i),
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

  void open(BuildContext context, AssetEntity asset) {
    showDialog(
      context: context,
      builder: (_) {
        return FutureBuilder<File>(
          future: asset.file,
          builder: (_, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            return SimpleDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              children: [
                Histogram(image: FileImage(snapshot.data)),
              ],
            );
          },
        );
      },
    );
  }

  void openGallery(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Gallery(items: assetList, index: index),
      ),
    );
  }
}
