import 'package:flutter/material.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

import 'interface_impl/dispatcher_impl.dart';
import 'interface_impl/viewer_impl.dart';
import 'interface/dispatcher.dart';
import 'interface/viewer.dart';
import 'instance_paint.dart';

class CascadeStringDispatcher<Dst extends Dispatcher> extends CascadeDispatcher<Dst, String> {
  final Viewer<StringDispatcher> source;
  CascadeStringDispatcher({required this.source, required Dst Function(Viewer<String> source) builder})
      : super(source: source, builder: builder);

  String? get str => source.get()?.str;

  ListDispatcher<String>? _appendDispatcher;

  @override
  List<TokenViewer<Dst>>? performGet() {
    _appendDispatcher = <String>[].dispatcher();
    return super.performGet();
  }

  @override
  Dispatcher<String>? rebuildSource() {
    get()?.getRange(length - appendCount, length).forEach((e) => e.get()?.flash());
    _appendDispatcher?.source.get().on(notNull: (v) => source.get()?.tail = v.join());
    source.get()?.flash();
    return super.rebuildSource();
  }

  int get appendCount => _appendDispatcher?.length ?? 0;

  TokenViewer<Dst>? append({required String init}) {
    var out = get(), viewer = _appendDispatcher?.append(init);
    if (viewer == null || out == null) return null;
    var disp = builder(viewer)..owner = this;
    var granule = SimpleTokenViewer(owner: this, getter: () => disp);
    out.add(granule);
    return granule;
  }

  bool removeAppend(Object element, [int start = 0]) {
    int idx = -1;
    if (element is TokenViewer<Dst>) {
      idx = get()?.indexOf(element, start + length - appendCount) ?? -1;
    } else if (element is Dst) {
      idx = _appendDispatcher?.indexOf(element.source, start) ?? -1;
    }
    if (idx >= 0) {
      get()?.removeAt(idx);
      _appendDispatcher?.remove(idx);
      return true;
    }
    return false;
  }
}

class InstanceLabelDispatcher extends StringDispatcher {
  InstanceLabelDispatcher({required Viewer<String> source, required Pattern pattern})
      : super(source: source, pattern: pattern);
  InstancePaint paint = InstancePaint.defaultPaint;
  void draw(Canvas canvas, Size size, Paint paint) => this.paint.draw(canvas, size, paint, this);
}

class ImageLabelDispatcher extends CascadeStringDispatcher<InstanceLabelDispatcher> {
  final Viewer<String> imageLabel;
  final Pattern instancePattern;
  final Pattern elementPattern;
  ImageLabelDispatcher({required this.imageLabel, required this.elementPattern, required this.instancePattern})
      : super(
            source: ValueViewer(imageLabel.dispatcher(instancePattern)),
            builder: (v) => InstanceLabelDispatcher(source: v, pattern: elementPattern));

  /// ?????????????????????????????????uri???
  String? get uri => owner.label is TextViewer ? owner.label.uri : null;
}

class LabelDispatcher extends CascadeStringDispatcher<ImageLabelDispatcher> {
  final Viewer<String> label;
  final Pattern imagePattern;
  final Pattern instancePattern;
  final Pattern elementPattern;

  LabelDispatcher(
      {required this.label, required this.imagePattern, required this.instancePattern, required this.elementPattern})
      : super(
            source: ValueViewer(label.dispatcher(imagePattern)),
            builder: (v) =>
                ImageLabelDispatcher(imageLabel: v, elementPattern: elementPattern, instancePattern: instancePattern));
}

LabelDispatcher singleLabelsTextViewerTest() {
  var str = """
00001.jpg 2
10 20 30 40 5
50 40 30 20 1
00002.jpg 1
2 1 3 5 6
00003.jpg 0
00004.jpg 3
1.2 5.6 3 2 3
1 2 3 5 6
2 3 4 6 2
""";
  {
    var labelsTxt = ValueViewer(str);
    // ???jpg????????????
    var allImages = labelsTxt.dispatcher(RegExp(r"\w+.jpg[^]*?((?=\w+.jpg)|$)"));
    print(allImages);

    // ????????????????????????jpg?????????
    var firstImage = allImages.get()?[0];
    var allInstances = firstImage?.dispatcher(RegExp(r"\n.+"));
    print(allInstances);

    // ???????????????????????????????????????
    var firstInstance = allInstances?.get()?[0];
    var allElements = firstInstance?.dispatcher(RegExp(r"\S+"));

    print("left: ${allElements?[0]},"
        "top: ${allElements?[1]},"
        "right: ${allElements?[2]},"
        "bottom: ${allElements?[3]},"
        "label: ${allElements?[4]},");

    allElements?[3] = "2021";
    allElements?.flash();
    allInstances?.flash();
    allImages.flash();
    print(labelsTxt.get());
  }
  // ?????????????????????????????????
  {
    var labelsTxt = ValueViewer(str);
    var dispatcher = LabelDispatcher(
        label: labelsTxt,
        imagePattern: RegExp(r"\w+.jpg[^]*?((?=\w+.jpg)|$)"),
        instancePattern: RegExp(r"\n.+"),
        elementPattern: RegExp(r"\S+"));
    // LabelsTextDispatcher???????????????????????????????????????????????????????????????????????????????
    print(dispatcher is Dispatcher<Dispatcher<Dispatcher<String>>>);

    var allElements = dispatcher[0]?[0];

    print("left: ${allElements?[0]},"
        "top: ${allElements?[1]},"
        "right: ${allElements?[2]},"
        "bottom: ${allElements?[3]},"
        "label: ${allElements?[4]},");
    allElements?[3] = "2021";
    dispatcher.flash();
    print(labelsTxt.get());
    print(dispatcher[0]?.str);
  }
  print("========??????????????????========");
  var viewer = ValueViewer(str);
  var dispatcher = LabelDispatcher(
      label: viewer,
      imagePattern: RegExp(r"\w+.jpg[^]*?((?=\w+.jpg)|$)"),
      instancePattern: RegExp(r"\n.+"),
      elementPattern: RegExp(r"\S+"));
  var image = dispatcher.append(init: "00005.jpg 10\n")?.get();
  image?.append(init: "0 1.0 3.0 4.0 5\n");
  var instance = image?.append(init: "20 10 30 40 8\n")?.get();
  instance?[1] = "2022";
  dispatcher.flash();
  print(dispatcher.str);

  return LabelDispatcher(
      label: TextViewer("file://e:\\labels\\label.txt")..set(str),
      imagePattern: RegExp(r"\w+.jpg[^]*?((?=\w+.jpg)|$)"),
      instancePattern: RegExp(r"\n.+"),
      elementPattern: RegExp(r"\S+"));
}
