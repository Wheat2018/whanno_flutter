import 'dart:io';

import 'package:flutter/material.dart';
import '../interface/viewer.dart';

class SimpleViewer<T> with Getter<T>, Setter<T>, Viewer<T> {
  final T? Function()? getter;
  final void Function(T data)? setter;
  SimpleViewer({this.getter, this.setter});

  @override
  T? performGet() => getter?.call();

  @override
  void performSet(T data) => setter?.call(data);
}

class ValueViewer<T> extends CacheViewer<T> {
  ValueViewer(T initValue) {
    cache = initValue;
  }
  @override
  T? performGet() => cache;

  @override
  void performSet(T data) => cache = data;
}

class SimpleTokenViewer<T> extends TokenViewer<T> implements SimpleViewer<T> {
  final T? Function()? getter;
  final void Function(T data)? setter;
  SimpleTokenViewer({required Tokenize owner, this.getter, this.setter, int? token})
      : super(owner: owner, token: token);

  @override
  T? performGet() => getter?.call();

  @override
  void performSet(T data) => setter?.call(data);
}

T? _onUri<T>(String uri,
    {T? Function(String path)? onPath,
    T? Function(String url)? onUrl,
    void Function(Object e, StackTrace stack)? onErorr}) {
  try {
    return (uri.startsWith("file://") ? onPath?.call(uri.replaceFirst("file://", "")) : onUrl?.call(uri));
  } catch (e, stack) {
    onErorr?.call(e, stack);
  }
}

class TextViewer extends CacheViewer<String> {
  final String uri;
  TextViewer(this.uri);

  @override
  void performSet(String data) {
    _onUri(uri,
        onPath: (path) => File(path).writeAsString(data),
        onUrl: (url) {
          // TODO: 网络txt写入。
          throw UnimplementedError;
        });
  }

  @override
  String? performGet() {
    return _onUri(uri,
        onPath: (path) => File(path).readAsStringSync(),
        onUrl: (url) {
          // TODO: 网络txt读取。
          throw UnimplementedError;
        });
  }
}

class ImageGetter extends CacheGetter<ImageProvider> {
  final String uri;
  ImageGetter(this.uri);

  @override
  ImageProvider<Object>? performGet() {
    return _onUri(uri, onPath: (path) => FileImage(File(path)), onUrl: (url) => NetworkImage(url));
  }
}

class FileListGetter extends CacheGetter<List<String>> {
  final String uri;
  FileListGetter(this.uri);

  @override
  List<String>? performGet() {
    return _onUri(uri,
        onPath: (path) => Directory(path).listSync().map((event) => event.path).toList(),
        onUrl: (url) {
          // TODO: 网络文件列表读取。
          throw UnimplementedError;
        });
  }
}
