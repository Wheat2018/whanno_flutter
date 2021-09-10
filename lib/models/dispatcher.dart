import 'package:flutter/material.dart';
import 'package:whanno_flutter/models/viewer.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

/// 令牌约束。
abstract class Tokenize {
  int get token;
}

/// 带令牌的观察器约束。观察器的令牌在构造时生成，每次`get`和`set`操作会检验`owner`的令牌。
abstract class TokenViewer<T> with Getter<T>, Setter<T>, Viewer<T> implements Tokenize {
  final int token;
  TokenViewer({required Tokenize owner, int? token}) : token = token ?? owner.token {
    super.owner = owner;
  }

  /// 令牌审查失败回调。其返回值会经由`get`或`set`返回给后两者的主调方。
  static Null Function(TokenViewer)? onArrest = (v) {
    assert(false, "TokenViewer: token block! ${v.token} != ${v.owner.token}");
  };

  @override
  T? get() => token == owner.token ? super.get() : onArrest?.call(this);
  @override
  void set(data) => token == owner.token ? super.set(data) : onArrest?.call(this);
}

/// 描述[Granule]类型颗粒的分发器的约束。
///
/// ---
///
/// 考虑这样的场景：我们持有一长串文字"You are my $someone. I need your $something."。
///
/// 我们希望将文字中的"$someone"分发给下级A，让他根据某些规则将占位符替换成实际角色名；
/// 我们希望将文字中的"$something"分发给下级B，让他根据某些规则将占位符替换成实际物品名；
///
/// 从防止耦合的角度考虑，我们不应该告诉下级如何检索占位符的位置（比如告诉下级A：你负责的字符串从下标`11`到`19`），
/// 而是应该生成一个等效可读写观察者委托给下级，下级在观察者当中的读取或修改，都是直接影响其原本数据的。
/// 这样的观察者，称为“颗粒观察者”。
///
/// 分发器的职责就是：从`source`源数据生成若干个的颗粒观察者[Viewer\<Granule\>]，并分发出去。
///
/// ---
///
/// 注意一：颗粒影响对象是分发器内部数据，而非`source`，分发器应该在某个合适时机将源数据缓存写至`source`。
///
/// 注意二：分发器构造时（或`reload`时）创建源数据的映像，在调用`flash`时将映像写至源数据。这表示
/// 源数据若在分发器构造后受到来自颗粒以外的修改，那么颗粒的读取可能是不及时的、颗粒的写入可能是未定义的。
///
/// 提示：使用索引器访问和修改颗粒，可以完美避免注意事项二。（在构建级联分发器或是某些只依赖颗粒观察器的场景，
/// 无法直接取得分发器，亦即无法使用分发器索引器，则需要考虑注意事项二）
abstract class Dispatcher<Granule> extends CacheGetter<List<Viewer<Granule>>> {
  Viewer get source;

  /// 重新分发颗粒。调用`get()`以获得颗粒。
  @override
  void reload();

  /// 使用[CacheGetter]父级实现即可，此处只是为了覆盖注释文本。

  /// 生成回写数据。该方法应该是protected的，外部应调用`flash()`而不是`rebuildSource()`。
  @protected
  dynamic rebuildSource();

  /// 将颗粒影响的源数据映像立即写回源数据。一次分发可多次回写。
  void flash() => source.set(rebuildSource());

  Granule? operator [](int i) => get()?[i].get();
  void operator []=(int i, Granule? data) => get()?[i].set(data);
  int get length => get()?.length ?? 0;
  Iterable<Granule?> get iterator sync* {
    for (int i = 0; i < length; i++) yield this[i];
  }
}

/// 对分发器的源数据的类型进行强约束。对于每个分发器实现来说，这个接口是可选实现的。
abstract class SourceManager<T> {
  Viewer<T> get source;
  dynamic rebuildSource();
}

/// 带令牌的分发器约束。相比于[Dispatcher]增加了令牌机制，分发器可以随时重签令牌，以使得之前分发出去的颗粒立即失效。
/// 若将令牌重签规则绑定到对源数据的内容审查上，可以一定程度上规避[Dispatcher]的注意事项二，即源数据受到未知修改时，
/// 颗粒立即失效，等待分发器重发。
abstract class TokenDispatcher<Granule> extends Dispatcher<Granule> implements Tokenize {
  @override
  List<TokenViewer<Granule>>? get() => super.get() as dynamic; // 收缩返回类型。

  @override
  List<TokenViewer<Granule>>? performGet(); // 收缩返回类型。

  @override
  void reload() {
    _token = Object().hashCode;
    super.reload();
  }

  /// 分发器令牌。
  ///
  /// 使用一：分发颗粒时重签令牌，以便每次重新分发颗粒时，使旧颗粒失效。
  ///
  /// 使用二：令牌等于映像的`hashCode`，以便颗粒绑定到映像上。
  /// 若重发颗粒时不重新生成映像，则旧颗粒不失效，反之失效，退化到“使用一”的情况；
  ///
  /// 不重写的情况下，使用方式一。
  @override
  int get token => _token;

  int _token = 0;
}

// ----impl----

class _IndexViewer<E> extends TokenViewer<E> {
  final int index;
  final List<E> list;
  _IndexViewer(this.list, this.index, {required Tokenize owner, int? token}) : super(owner: owner, token: token);

  @override
  E? performGet() => list[index];

  @override
  void performSet(E data) => list[index] = data;
}

/// 列表分发器。将列表元素逐个分发。一般而言，对颗粒的读写是直接作用在原列表元素上的，因此不需要调用`flash`回写。
class ListDispatcher<E> extends TokenDispatcher<E> implements SourceManager<List<E>> {
  final Viewer<List<E>> source;
  ListDispatcher({required this.source});

  List<E>? _list; // 映像

  @override
  List<TokenViewer<E>>? performGet() {
    var list = source.get();
    if (list == null) return null;
    _list = list;
    return List.generate(list.length, (index) => _IndexViewer(list, index, owner: this));
  }

  @override
  List<E>? rebuildSource() => _list;
}

extension ToListDispatcher<E> on List<E> {
  ListDispatcher<E> dispatcher() => ListDispatcher(source: ValueViewer(this));
}

class StringDispatcher extends TokenDispatcher<String> implements SourceManager<String> {
  final Viewer<String> source;
  Pattern pattern;
  StringDispatcher({required this.source, required this.pattern});

  String? _str; // 映像
  List<String>? _strImage; // 映像
  Map<int, int>? _matches; // 映像

  @override
  List<TokenViewer<String>>? performGet() {
    var str = source.get();
    if (str == null) return null;
    var matches = pattern.allMatches(str).map((e) => e.group(0).on(notNull: (v) => MapEntry(e.start, v)));
    var map = Map.fromEntries(matches.skipNull());
    _matches = Map.fromIterables(map.keys, Iterable.generate(map.length));
    _strImage = map.values.toList();
    _str = str;
    return ListDispatcher(source: ValueViewer(_strImage!)).get();
  }

  @override
  String? rebuildSource() {
    var str = _str, strImage = _strImage, matches = _matches;
    if (str == null || strImage == null || matches == null) return null;
    str = str.replaceAllMapped(pattern, (m) => matches[m.start].on(notNull: (i) => strImage[i]) ?? m.group(0) ?? "");
    return head + str + tail;
  }

  /// 字符串头部。修改此字段可在源字符串头部追加数据。
  String head = "";

  /// 字符串尾部。修改此字段可在源字符串尾部追加数据。
  String tail = "";
}

extension ToStringDispatcher on Viewer<String> {
  StringDispatcher dispatcher(Pattern pattern) => StringDispatcher(source: this, pattern: pattern);
}

class ExpandDispatcher<Granule> extends TokenDispatcher<Granule>
    implements SourceManager<List<TokenDispatcher<Granule>>> {
  /// [ExpandDispatcher]本身只用到了`source`的[Iterable]特性，但此处仍然要求`source`是个[List]，
  /// 这是考虑到使用方可能在[Iterable]闭包中构造[Dispatcher]，导致每次使用`source`迭代时重复构造[Dispatcher]，
  /// 从而可能引发性能问题以及多个映像指向同一数据源的问题。
  final Viewer<List<TokenDispatcher<Granule>>> source;
  ExpandDispatcher({required this.source});

  ExpandDispatcher.fromList(List<TokenDispatcher<Granule>> list) : source = ValueViewer(list);

  @override
  List<TokenViewer<Granule>>? performGet() => source.get()?.map((e) => e.get()).skipNull().expand((e) => e).toList();

  @override
  List<TokenDispatcher<Granule>>? rebuildSource() => source.get()?..forEach((e) => e.flash());
}
