import 'dart:async';

import 'package:flutter/material.dart';

extension NotNull<T> on T? {
  /// 对象是否为空分支调用。
  R? on<R>({R? Function(T)? notNull, R? Function()? justNull}) =>
      this == null ? justNull?.call() : notNull?.call(this!);
}

extension StringUtils on String {
  String get filename => RegExp(r"(.*[\\/])*([^.]+).*").firstMatch(this)?.group(2) ?? "";
}

extension IterableUtils<T> on Iterable<T?> {
  Iterable<T> skipNull() => whereType<T>();
  bool get hasNull => whereType<Null>().isNotEmpty;
  static Iterable<int> get growing => Iterable.generate(1 << 62);
}

extension ImageProviderUtils on ImageProvider {
  Future<Size> get size {
    var size = Completer<Size>();
    var listener;
    resolve(ImageConfiguration.empty).addListener(listener = ImageStreamListener((info, _) {
      size.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
      resolve(ImageConfiguration.empty).removeListener(listener);
    }));
    return size.future;
  }
}
