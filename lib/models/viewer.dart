import 'dart:async';

import 'package:flutter/material.dart';

abstract class CacheGetter<T> with Getter<T> {
  @protected
  late FutureOr<T?> cache;

  CacheGetter() {
    reload();
  }

  /// 更新缓存`cache`
  void reload() => cache = grab();
}

abstract class Getter<T> {
  dynamic owner;

  /// 抓取目标数据的副本。一般抓取数据为`null`表示抓取失败。
  FutureOr<T?> get() => grab();

  /// 数据实际抓取方式。该方法是protected的，外部应调用`get()`而不是`grab()`。
  @protected
  FutureOr<T?> grab();
}

abstract class Setter<T> {
  dynamic owner;

  /// 以指定数据重写至目标。一般指定`null`时表示立即将缓存区（如有）写至目标。
  FutureOr set(T? data);
}

mixin Viewer<T> on Getter<T>, Setter<T> {}

abstract class CacheViewer<T> extends CacheGetter<T> with Setter<T>, Viewer<T> {}

class SimpleViewer<T> with Getter<T>, Setter<T>, Viewer<T> {
  final FutureOr<T?> Function()? getter;
  final FutureOr Function(T? data)? setter;
  SimpleViewer({this.getter, this.setter});

  @override
  FutureOr<T?> grab() => getter?.call();

  @override
  FutureOr set(T? data) => setter?.call(data);
}
