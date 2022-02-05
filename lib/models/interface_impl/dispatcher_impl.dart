import 'package:whanno_flutter/utils/extension_utils.dart';
import 'viewer_impl.dart';
import '../interface/dispatcher.dart';
import '../interface/viewer.dart';

/// 列表分发器。将列表元素逐个分发。一般而言，对颗粒的读写是直接作用在原列表元素上的，因此不需要调用`flash`回写
/// （除非 `source`返回列表为临时对象）。但如果需要，可调用`flash`重置`modified`状态。
class ListDispatcher<E> extends TokenDispatcher<E> implements SourceManager<List<E>> {
  final Viewer<List<E>> source;
  ListDispatcher({required this.source});

  List<E>? _list; // 映像

  bool _modified = false;

  /// 列表元素是否被修改。
  bool get modified => _modified;

  @override
  List<TokenViewer<E>>? performGet() {
    var list = _list = source.get();
    if (list == null) return null;
    _modified = false;
    return List.generate(list.length, _genIndexViewer);
  }

  @override
  List<E>? rebuildSource() => (this.._modified = false)._list;

  TokenViewer<E> _genIndexViewer(int i) {
    return SimpleTokenViewer<E>(
        owner: this,
        getter: () => _list?[i],
        setter: (data) {
          var list = _list;
          if (list == null) return;
          if (list[i] != data) _modified = true;
          list[i] = data; // []=运算符可能有其他操作，即便相等也应调用一遍。
        });
  }

  TokenViewer<E>? append(E data) {
    var list = _list, out = get();
    if (list == null || out == null) return null;
    list.add(data);
    var viewer = _genIndexViewer(list.length - 1);
    out.add(viewer);
    _modified = true;
    return viewer;
  }

  int indexOf(Object element, [int start = 0]) {
    if (element is E) return _list?.indexOf(element as E, start) ?? -1;
    if (element is TokenViewer<E>) return get()?.indexOf(element, start) ?? -1;
    if (element is int) return element >= 0 && element < length ? element : -1;
    return -1;
  }

  bool remove(Object element, [int start = 0]) {
    int idx = indexOf(element, start);
    if (idx >= 0) {
      _list?.removeAt(idx);
      get()?.removeAt(idx);
      _modified = true;
      return true;
    }
    return false;
  }
}

extension ToListDispatcher<E> on List<E> {
  ListDispatcher<E> dispatcher() => ListDispatcher(source: ValueViewer(this));
}

class StringDispatcher extends TokenDispatcher<String> implements SourceManager<String> {
  final Viewer<String> source;
  Pattern pattern;
  StringDispatcher({required this.source, required this.pattern});

  String? get str => source.get();

  String? _str; // 映像
  ListDispatcher<String>? _substrs; // 映像
  Map<int, int>? _matches; // 映像

  @override
  int get token => _substrs?.token ?? 0;

  @override
  List<TokenViewer<String>>? performGet() {
    head = "";
    tail = "";
    var str = _str = source.get();
    if (str == null) return null;
    var matches = pattern.allMatches(str).map((e) => e.group(0).on(notNull: (v) => MapEntry(e.start, v)));
    var map = Map.fromEntries(matches.skipNull());
    _matches = Map.fromIterables(map.keys, Iterable.generate(map.length));
    _substrs = map.values.toList().dispatcher();
    return _substrs?.get()?..forEach((e) => e.owner = this);
  }

  @override
  String? rebuildSource() {
    var str = _str, substrs = _substrs, matches = _matches;
    if (str == null || substrs == null || matches == null) return null;
    if (substrs.modified) {
      var strs = substrs.source.get();
      if (strs != null) {
        str = str.replaceAllMapped(pattern, (m) => matches[m.start].on(notNull: (i) => strs[i]) ?? m.group(0) ?? "");
        substrs.flash(); // 重置modified
      }
    }
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

/// 展开分发器列表的颗粒。注意[ExpandDispatcher]只做转发，其`reload`并不能使旧颗粒失效，
/// 要使旧颗粒失效应调用`source`中受托管[Dispatcher]的`reload`。
class ExpandDispatcher<Granule> extends TokenDispatcher<Granule>
    implements SourceManager<List<TokenDispatcher<Granule>>> {
  /// [ExpandDispatcher]本身只用到了`source`的[Iterable]特性，但此处仍然要求`source`是个[List]，
  /// 这是考虑到使用方可能在[Iterable]闭包中构造[Dispatcher]，导致每次使用`source`迭代时重复构造[Dispatcher]，
  /// 从而可能引发性能问题以及多个映像指向同一数据源的问题。
  final Viewer<List<TokenDispatcher<Granule>>> source;
  ExpandDispatcher({required this.source});

  ExpandDispatcher.fromList(List<TokenDispatcher<Granule>> list) : source = ValueViewer(list);

  @override
  List<TokenViewer<Granule>>? performGet() => source.get()?.map((e) => e.get()).skipNull().expand((e) => e).toList();

  @override
  List<TokenDispatcher<Granule>>? rebuildSource() => source.get()?..forEach((e) => e.flash());

  ExpandDispatcher<Granule> operator +(TokenDispatcher<Granule> other) {
    if (other is ExpandDispatcher<Granule>)
      return ExpandDispatcher.fromList((source.get() ?? []) + (other.source.get() ?? []));
    return ExpandDispatcher.fromList((source.get() ?? []) + [other]);
  }
}

extension ToExpandDispatcher<Granule> on TokenDispatcher<Granule> {
  ExpandDispatcher<Granule> operator +(TokenDispatcher<Granule> other) => ExpandDispatcher.fromList([this, other]);
}

class CascadeDispatcher<Dst extends Dispatcher, SrcGranule> extends TokenDispatcher<Dst>
    implements SourceManager<Dispatcher<SrcGranule>> {
  final Viewer<Dispatcher<SrcGranule>> source;
  final Dst Function(Viewer<SrcGranule> source) builder;
  CascadeDispatcher({required this.source, required this.builder});

  Dispatcher<SrcGranule>? _dispatcher;
  ListDispatcher<Dst>? _granules;

  @override
  int get token => _granules?.token ?? 0;

  @override
  List<TokenViewer<Dst>>? performGet() {
    var dispatcher = _dispatcher = source.get();
    if (dispatcher == null) return null;
    _granules = dispatcher.get()?.map((e) => builder(e)..owner = this).toList().dispatcher();
    return _granules?.get()?..forEach((e) => e.owner = this);
  }

  @override
  Dispatcher<SrcGranule>? rebuildSource() {
    _granules?.source.get()?.forEach((e) => e.flash());
    return _dispatcher;
  }
}
