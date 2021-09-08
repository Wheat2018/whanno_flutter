import 'package:whanno_flutter/models/dispatcher.dart';
import 'package:whanno_flutter/models/viewer.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

void singleTextLablesViewerTest() {
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
  var labelsTxt = ValueViewer(str);
  // 按jpg切割文本
  var allImages = StringDispatcher(source: labelsTxt, pattern: RegExp(r"\w+.jpg.+\n(([0-9.]+ *)*\n)*"));
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
