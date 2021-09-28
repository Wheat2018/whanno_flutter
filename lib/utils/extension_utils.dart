import 'dart:async';

import 'package:flutter/material.dart';

extension NotNull<T> on T? {
  /// 对象是否为空分支调用。
  R? on<R>({R? Function(T)? notNull, R? Function()? justNull}) =>
      this == null ? justNull?.call() : notNull?.call(this!);
}

extension StringUtils on String {
  Iterable<String> separate(Iterable<int>? separator) sync* {
    int start = 0;
    if (separator != null) {
      for (var sep in separator) {
        if (sep < start)
          yield "";
        else {
          yield substring(start, sep);
          start = sep;
        }
      }
    }
    yield substring(start);
  }

  String join(Iterable<String> strings) {
    if (strings.isEmpty) return this;
    var buffer = StringBuffer(this);
    strings.forEach(buffer.write);
    return buffer.toString();
  }
}

extension IterableUtils<T> on Iterable<T?> {
  Iterable<T> skipNull() => whereType<T>();
  bool get hasNull => whereType<Null>().isNotEmpty;
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
