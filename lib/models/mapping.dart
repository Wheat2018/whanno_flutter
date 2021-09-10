import 'package:whanno_flutter/models/common_viewer.dart';
import 'package:whanno_flutter/models/dispatcher.dart';

class LabelImage {
  final String key;
  LabelImage(this.key);
  final List<ImageGetter> images = [];
  final List<Dispatcher<StringDispatcher>> labels = [];
  void pushImage(ImageGetter image) => images.add(image);
  void pushLabel(Dispatcher<StringDispatcher> label) => labels.add(label);

  ImageGetter get image => images[0];
  Dispatcher<StringDispatcher> get label => labels[0];

  bool get valid => images.length == 1 && labels.length == 1;
}

typedef StringMapping = String Function(String);

String defaultStringMapping(String value) => value;

Map<String, LabelImage> mapping(
    {required Iterable<ImageGetter> images,
    required Iterable<Dispatcher<StringDispatcher>> labels,
    StringMapping imageKey = defaultStringMapping,
    StringMapping labelKey = defaultStringMapping}) {
  Map<String, LabelImage> map = {};
  for (var image in images) {
    var key = imageKey(image.uri);
    map.putIfAbsent(key, () => LabelImage(key)).pushImage(image);
  }
  for (var label in labels) {
    String? text = label.owner.get();
    if (text == null) continue;
    String key = labelKey(text);
    map.putIfAbsent(key, () => LabelImage(key)).pushLabel(label);
  }
  return map;
}
