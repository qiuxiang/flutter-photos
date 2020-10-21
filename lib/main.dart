import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

main() {
  runApp(App());
}

class App extends StatelessWidget {
  build(context) {
    return MaterialApp(title: 'Photos', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  createState() => HomePageState();
}

class HomePageState extends State {
  AssetPathEntity path;
  int pageSize = 20;
  List<AssetEntity> assetList = [];

  initState() {
    super.initState();
    PhotoManager.requestPermission().then((success) async {
      if (success) {
        final pathList = await PhotoManager.getAssetPathList(onlyAll: true);
        path = pathList[0];
        getAssetList();
      }
    });
  }

  getAssetList() async {
    assetList = await path.getAssetListPaged(0, pageSize);
    setState(() {});
  }

  build(context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photos')),
      body: GridView.builder(
        itemCount: assetList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, i) {
          return LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return FutureBuilder<Uint8List>(
              future: assetList[i].thumbData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data,
                    width: width,
                    height: width,
                    fit: BoxFit.cover,
                  );
                }
                return const SizedBox();
              },
            );
          });
        },
      ),
    );
  }
}
