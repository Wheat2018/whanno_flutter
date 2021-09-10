import 'package:whanno_flutter/models/dispatcher.dart';
import 'package:whanno_flutter/models/viewer.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

/// [LabelsTextDispatcher]是一种字符串分发器的分发器的分发器。🐶
class LabelsTextDispatcher extends TokenDispatcher<ListDispatcher<StringDispatcher>> implements SourceManager<String> {
  final Viewer<String> source;
  final Pattern imagePattern, instancePattern, elementPattern;
  LabelsTextDispatcher(
      {required this.source, required this.imagePattern, required this.instancePattern, required this.elementPattern});

  StringDispatcher? allImages;
  Map<StringDispatcher, List<StringDispatcher>>? allInstancesElements;

  @override
  List<TokenViewer<ListDispatcher<StringDispatcher>>>? performGet() {
    allImages = StringDispatcher(source: source, pattern: imagePattern);
    var eachImages = allImages!.get();
    if (eachImages == null) return null;
    allInstancesElements = Map.fromEntries(eachImages.map((e) {
      var key = e.dispatcher(instancePattern)..owner = allImages;
      var value = key.get()?.map((e) => e.dispatcher(elementPattern)..owner = key).toList();
      return value == null ? null : MapEntry(key, value);
    }).skipNull());
    var allElements = allInstancesElements?.entries.map((e) => e.value.dispatcher()..owner = e.key).toList();
    var allInstances = allElements?.dispatcher()?..owner = allImages;
    return allInstances?.get();
  }

  @override
  String? rebuildSource() {
    allInstancesElements?.values.forEach((list) => list.forEach((e) => e.flash()));
    allInstancesElements?.keys.forEach((e) => e.flash());
    allImages?.flash();
  }
}

void singleLablesTextViewerTest() {
  var str = """
00001.jpg 2
1 2 3 4 5
5 4 3 2 1
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
    // 按jpg切割文本
    var allImages = labelsTxt.dispatcher(RegExp(r"\w+.jpg[^]*?((?=\w+.jpg)|$)"));
    print(allImages);

    // 按实例切割第一张jpg的文本
    var firstImage = allImages.get()?[0];
    var allInstances = firstImage?.dispatcher(RegExp(r"\n.+"));
    print(allInstances);

    // 按元素切割第一个实例的文本
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
  // ⬆️⬇️两种写法等效。
  {
    var labelsTxt = ValueViewer(str);
    var dispatcher = LabelsTextDispatcher(
        source: labelsTxt,
        imagePattern: RegExp(r"\w+.jpg[^]*?((?=\w+.jpg)|$)"),
        instancePattern: RegExp(r"\n.+"),
        elementPattern: RegExp(r"\S+"));
    // LabelsTextDispatcher是一种分发分发分发字符串的分发器的分发器的分发器。🐶
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
    print(dispatcher[0]?.owner.source.get());
  }
}
