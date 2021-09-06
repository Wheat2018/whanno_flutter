import 'dart:async';

import 'package:flutter/material.dart';

extension NotNull<T> on T? {
  dynamic on({Function(T)? notNull, Function()? justNull}) => this == null ? justNull?.call() : notNull?.call(this!);
}

/// 描述可从[Getter\<T\>]实例中获取[T]类型实例的约束。
abstract class Getter<T> {
  dynamic owner;

  /// 抓取目标数据的副本。一般抓取数据为`null`表示抓取失败。
  FutureOr<T?> get() => performGet();

  /// 数据实际抓取方式。该方法是protected的，外部应调用`get()`而不是`grab()`。
  @protected
  FutureOr<T?> performGet();
}

/// 描述可将[T]类型实例写入[Setter\<T\>]实例的约束。
abstract class Setter<T> {
  dynamic owner;

  /// 以指定数据重写至目标。一般指定`null`时表示立即将缓存区（如有）写至目标。
  FutureOr set(T? data) => data.on(notNull: performSet);

  /// 数据实际写入方式。该方法是protected的，外部应调用`set()`而不是`flash()`。
  @protected
  FutureOr performSet(T data);
}

/// 描述对[T]类型实例的等效可读写观察者的约束
mixin Viewer<T> on Getter<T>, Setter<T> {}

abstract class CacheGetter<T> with Getter<T> {
  @protected
  FutureOr<T?> cache;

  CacheGetter() {
    reload();
  }

  /// 对于[CacheGetter]，`get()`返回值是缓冲区副本。获取最新副本应提前调用`reload`。
  @override
  FutureOr<T?> get() => cache;

  /// 更新缓存`cache`
  void reload() => cache = performGet();
}

abstract class CacheViewer<T> extends CacheGetter<T> with Setter<T>, Viewer<T> {
  FutureOr _cacheThenSet(T data) => performSet(cache = data);

  Future _setByCache() async => (await cache).on(notNull: performSet);

  /// 对于[CacheViewer]，指定数据为`null`时将缓存写至目标，不为`null`时更新缓存并写至目标。
  @override
  FutureOr set(T? data) => data.on(notNull: _cacheThenSet, justNull: _setByCache);
}

// ----impl----

class SimpleViewer<T> with Getter<T>, Setter<T>, Viewer<T> {
  final FutureOr<T?> Function()? getter;
  final FutureOr Function(T? data)? setter;
  SimpleViewer({this.getter, this.setter});

  @override
  FutureOr<T?> performGet() => getter?.call();

  @override
  FutureOr performSet(T data) => setter?.call(data);
}

class ValueViewer<T> extends CacheViewer<T> {
  ValueViewer(T initValue) {
    cache = initValue;
  }
  @override
  FutureOr<T?> performGet() => cache;

  @override
  FutureOr performSet(T data) => cache = data;
}
