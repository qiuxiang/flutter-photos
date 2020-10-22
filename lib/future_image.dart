import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class FutureMemoryImage extends ImageProvider<FutureMemoryImage> {
  final Future<Uint8List> bytes;
  final double scale;

  const FutureMemoryImage(this.bytes, {this.scale = 1.0})
      : assert(bytes != null),
        assert(scale != null);

  @override
  ImageStreamCompleter load(FutureMemoryImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  @override
  Future<FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FutureMemoryImage>(this);
  }

  Future<Codec> _loadAsync(
      FutureMemoryImage key, DecoderCallback decode) async {
    assert(key == this);
    return decode(await bytes);
  }

  @override
  bool operator ==(Object o) {
    if (o.runtimeType != runtimeType) return false;
    return o is FutureMemoryImage && o.bytes == bytes && o.scale == scale;
  }

  @override
  int get hashCode => hashValues(bytes.hashCode, scale);
}

@immutable
class FutureFileImage extends ImageProvider<FutureFileImage> {
  const FutureFileImage(this.file, {this.scale = 1.0})
      : assert(file != null),
        assert(scale != null);

  final Future<File> file;
  final double scale;

  @override
  Future<FutureFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FutureFileImage>(this);
  }

  @override
  ImageStreamCompleter load(FutureFileImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<Codec> _loadAsync(key, DecoderCallback decode) async {
    assert(key == this);
    return await decode(await (await file).readAsBytes());
  }

  @override
  bool operator ==(Object o) {
    if (o.runtimeType != runtimeType) return false;
    return o is FutureFileImage && o.file == file && o.scale == scale;
  }

  @override
  int get hashCode => hashValues(file.hashCode, scale);
}
