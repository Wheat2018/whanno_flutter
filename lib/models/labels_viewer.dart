import 'package:whanno_flutter/models/dispatcher.dart';
import 'package:whanno_flutter/models/viewer.dart';

class SingleTextLabelsViewer extends StringDispatcher {
  SingleTextLabelsViewer({required Viewer<String> source, required RegExp? seg})
      : super(source: source, separator: source.get().on(notNull: (str) => seg?.allMatches(str).map((e) => e.start)));

  @override
  List<TokenViewer<String>>? get() => super.get()?.sublist(1);
}

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
  var value = ValueViewer(str);
  var labels = SingleTextLabelsViewer(source: value, seg: RegExp(r"\d+.jpg"));
}
