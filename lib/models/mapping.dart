import 'package:whanno_flutter/models/common_viewer.dart';
import 'package:whanno_flutter/models/labels_viewer.dart';

class SignedImage {
  final String key;
  SignedImage(this.key);
  final List<ImageGetter> images = [];
  final List<ImageLabelDispatcher> labels = [];
  void putImage(ImageGetter image) => images.add(image);
  void putLabel(ImageLabelDispatcher label) => labels.add(label);

  ImageGetter? get image => valid ? images.single : null;
  ImageLabelDispatcher? get label => valid ? labels.single : null;
  String? get labelUri => label?.uri;

  bool get valid => images.length == 1 && labels.length == 1;

  @override
  String toString() => super.toString() + "{${valid ? "valid" : "invalid"}, $image, $label}";
}

String matchFilename(String path) => RegExp(r"(.*[\\/])*([^.]+).*").firstMatch(path)?.group(2) ?? "";

Map<String, SignedImage> mapping(
    {required Iterable<ImageGetter> images,
    required Iterable<ImageLabelDispatcher> labels,
    String Function(String uri)? imageKey,
    String Function(String uri, String content)? labelKey}) {
  imageKey = imageKey ?? matchFilename;
  labelKey = labelKey ?? (uri, content) => uri.isNotEmpty ? matchFilename(uri) : content;
  Map<String, SignedImage> map = {};
  for (var image in images) {
    var key = imageKey(image.uri);
    map.putIfAbsent(key, () => SignedImage(key)).putImage(image);
  }
  for (var label in labels) {
    String? text = label.str;
    if (text == null) continue;
    String key = labelKey(label.uri ?? "", text);
    map.putIfAbsent(key, () => SignedImage(key)).putLabel(label);
  }
  return map;
}
