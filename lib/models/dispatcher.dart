import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whanno_flutter/models/viewer.dart';

/// 令牌约束。
abstract class Tokenize {
  FutureOr<int> get token;
}

/// 带令牌的观察器约束。观察器的令牌在构造时生成，每次`get`和`set`操作会检验`owner`的令牌。
abstract class TokenViewer<T> with Getter<T>, Setter<T>, Viewer<T> implements Tokenize {
  final FutureOr<int> token;
  TokenViewer({required Tokenize owner, int? token}) : token = token ?? owner.token {
    super.owner = owner;
  }

  /// 令牌审查失败回调。其返回值会经由`get`或`set`返回给后两者的主调方。
  late Function? onArrest = () => throw Exception("TokenViewer: token block! $token != ${owner.token}");

  @override
  FutureOr<T?> get() async => await token == await owner.token ? super.get() : onArrest?.call();
  @override
  FutureOr set(data) async => await token == await owner.token ? super.set(data) : onArrest?.call();
}

/// 描述由[Source]类型实例构造[Granule]类型颗粒的分发器的约束。
///
/// ---
///
/// 考虑这样的场景：我们持有一长串文字"You are my $someone. I need your $something."。
///
/// 我们希望将文字中的"$someone"分发给下级A，让他根据某些规则将占位符替换成实际角色名；
/// 我们希望将文字中的"$something"分发给下级B，让他根据某些规则将占位符替换成实际物品名；
///
/// 从防止耦合的角度考虑，我们不应该告诉下级如何检索占位符的位置（比如告诉下级A：你负责的字符串从下标`11`到`19`），
/// 而是应该生成一个等效可读写观察者委托给下级，下级在观察者当中的读取或修改，都是直接影响其原本数据的，这样的观察者，称之为“颗粒”。
///
/// 分发器的职责就是：从[Source]源数据生成若干个[Granule]类型的观察者（颗粒），并分发出去。
///
/// ---
///
/// 注意一：颗粒影响对象是分发器内部数据，而非[Source]源数据，分发器应该在某个合适时机将源数据缓存写至[Source]。
///
/// 注意二：分发器构造时（或`reload`时）创建源数据的映像，在调用`flash`时将映像写至源数据。这表示
/// 源数据若在分发器构造后受到来自颗粒以外的修改，那么颗粒的读取可能是不及时的、颗粒的写入可能是未定义的。
abstract class Dispatcher<Source, Granule> extends CacheGetter<Iterable<Viewer<Granule>>> {
  final Viewer<Source> source;
  Dispatcher({required this.source});

  /// 生成回写数据。该方法应该是protected的，外部应调用`flash()`而不是`rebuildSource()`。
  @protected
  FutureOr<Source?> rebuildSource();

  /// 将颗粒影响的源数据映像立即写回源数据。一次分发可多次回写。
  FutureOr flash() async => source.set(await rebuildSource());
}

/// 带令牌的分发器约束。相比于[Dispatcher]增加了令牌机制，分发器可以随时重签令牌，以使得之前分发出去的颗粒立即失效。
/// 若将令牌重签规则绑定到对源数据的内容审查上，可以一定程度上规避[Dispatcher]的注意事项二，即源数据受到未知修改时，
/// 颗粒立即失效，等待分发器重发。
abstract class TokenDispatcher<Source, Granule> extends Dispatcher<Source, Granule> implements Tokenize {
  TokenDispatcher({required Viewer<Source> source}) : super(source: source);

  @override
  FutureOr<Iterable<TokenViewer<Granule>>?> get() => super.get() as dynamic; // 强制绕过静态类型检查。

  @override
  FutureOr<Iterable<TokenViewer<Granule>>?> performGet();
}

// ----impl----

class _IndexViewer<E> extends TokenViewer<E> {
  final int index;
  final List<E> list;
  _IndexViewer(this.list, this.index, {required Tokenize owner, int? token}) : super(owner: owner, token: token);

  @override
  FutureOr<E?> performGet() => list[index];

  @override
  FutureOr performSet(E data) => list[index] = data;
}

/// 列表分发器。将列表元素逐个分发。一般而言，对颗粒的读写是直接作用在原列表元素上的，因此不需要调用`falsh`回写。
class ListDispatcher<E> extends TokenDispatcher<List<E>, E> {
  ListDispatcher({required Viewer<List<E>> source}) : super(source: source);

  int _token = 0;

  @override
  FutureOr<int> get token => _token;

  @override
  FutureOr<List<TokenViewer<E>>?> get() => super.get() as dynamic; // 强制绕过静态类型检查。

  @override
  FutureOr<List<TokenViewer<E>>?> performGet() async {
    var list = await source.get(); // 映像
    if (list == null) return null;
    _token = list.hashCode + list.length;
    return List.generate(list.length, (index) => _IndexViewer(list, index, owner: this));
  }

  @override
  FutureOr<List<E>?> rebuildSource() => source.get();
}

extension on String {
  Iterable<String> separate(Iterable<int> separator) sync* {
    int start = 0;
    for (var sep in separator) {
      if (sep < start)
        yield "";
      else {
        yield substring(start, sep);
        start = sep;
      }
    }
    yield substring(start);
  }

  String join(Iterable<String> strings) {
    var buffer = StringBuffer(this);
    strings.forEach(buffer.write);
    return buffer.toString();
  }
}

class StringDispatcher extends TokenDispatcher<String, String> {
  Iterable<int> separator;
  StringDispatcher({required Viewer<String> source, required this.separator}) : super(source: source);

  int _token = 0;

  @override
  FutureOr<int> get token => _token;

  List<String> _strImage = []; // 映像

  @override
  FutureOr<List<TokenViewer<String>>?> get() => super.get() as dynamic;

  @override
  FutureOr<List<TokenViewer<String>>?> performGet() async {
    var str = await source.get();
    if (str == null) return null;
    _token = separator.hashCode + str.hashCode;
    _strImage = List.from(str.separate(separator));
    return ListDispatcher(source: ValueViewer(_strImage)).get();
  }

  @override
  FutureOr<String?> rebuildSource() => "".join(_strImage);
}
