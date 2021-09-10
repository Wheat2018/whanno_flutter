import 'package:flutter/material.dart';

import 'package:whanno_flutter/utils/extension_utils.dart';

/// 描述可从[Getter\<T\>]实例中获取[T]类型实例的约束。
abstract class Getter<T> {
  dynamic owner;

  /// 抓取目标数据的副本。一般抓取数据为`null`表示抓取失败。
  T? get() => performGet();

  /// 数据实际抓取方式。该方法是protected的，外部应调用`get()`而不是`grab()`。
  @protected
  T? performGet();

  @override
  String toString() => "$runtimeType{${get()}}";
}

/// 描述可将[T]类型实例写入[Setter\<T\>]实例的约束。
abstract class Setter<T> {
  dynamic owner;

  /// 以指定数据重写至目标。一般指定`null`时表示立即将缓存区（如有）写至目标。
  void set(T? data) => data.on(notNull: performSet);

  /// 数据实际写入方式。该方法是protected的，外部应调用`set()`而不是`flash()`。
  @protected
  void performSet(T data);
}

/// 描述对[T]类型实例的等效可读写观察者的约束
mixin Viewer<T> on Getter<T>, Setter<T> {}

abstract class CacheGetter<T> with Getter<T> {
  @protected
  T? cache;

  CacheGetter() {
    reload();
  }

  /// 对于[CacheGetter]，`get()`返回值是缓冲区副本。获取最新副本应提前调用`reload`。
  @override
  T? get() => cache;

  /// 更新缓存`cache`
  void reload() => cache = performGet();
}

abstract class CacheViewer<T> extends CacheGetter<T> with Setter<T>, Viewer<T> {
  void _cacheThenSet(T data) => performSet(cache = data);

  void _setByCache() => cache.on(notNull: performSet);

  /// 对于[CacheViewer]，指定数据为`null`时将缓存写至目标，不为`null`时更新缓存并写至目标。
  @override
  void set(T? data) => data.on(notNull: _cacheThenSet, justNull: _setByCache);
}

// ----impl----

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
