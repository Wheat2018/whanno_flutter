import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whanno_flutter/models/viewer.dart';

FutureOr<T?> _onUrl<T>(String uri,
    {FutureOr<T?> Function(String path)? onPath,
    FutureOr<T?> Function(String url)? onUrl,
    void Function(Object e, StackTrace stack)? onErorr}) async {
  try {
    return await (uri.startsWith("file://") ? onPath?.call(uri.replaceFirst("file://", "")) : onUrl?.call(uri));
  } catch (e, stack) {
    onErorr?.call(e, stack);
  }
}

class TextViewer extends CacheViewer<String> {
  final String uri;
  TextViewer(this.uri);

  @override
  FutureOr performSet(String data) async {
    await _onUrl(uri, onPath: (path) async {
      return await File(path).writeAsString(data);
    }, onUrl: (url) async {
      // TODO: 网络txt写入。
      throw UnimplementedError;
    });
  }

  @override
  FutureOr<String?> performGet() async {
    return await _onUrl(uri, onPath: (path) async {
      return await File(path).readAsString();
    }, onUrl: (url) async {
      // TODO: 网络txt读取。
      throw UnimplementedError;
    });
  }
}

class ImageGetter extends CacheGetter<ImageProvider> {
  final String uri;
  ImageGetter(this.uri);

  @override
  FutureOr<ImageProvider<Object>?> performGet() {
    return _onUrl(uri, onPath: (path) => AssetImage(path), onUrl: (url) => NetworkImage(url));
  }
}

class FileListGetter extends CacheGetter<List<String>> {
  final String uri;
  FileListGetter(this.uri);

  @override
  FutureOr<List<String>?> performGet() async {
    return await _onUrl(uri, onPath: (path) async {
      return Directory(path).list().map((event) => event.path).toList();
    }, onUrl: (url) async {
      // TODO: 网络文件列表读取。
      throw UnimplementedError;
    });
  }
}
