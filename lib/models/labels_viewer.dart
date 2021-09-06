import 'dart:async';

import 'package:whanno_flutter/models/common_viewer.dart';
import 'package:whanno_flutter/models/viewer.dart';

class SingleUriLabelTextViewer extends CacheViewer<List<Viewer<String>>> {
  String uri;
  SingleUriLabelTextViewer(this.uri) : text = TextViewer(uri);

  final TextViewer text;

  @override
  FutureOr performSet(List<Viewer<String>>? data) {
    if (data != null && data != cache) cache = data;
  }

  @override
  FutureOr<List<Viewer<String>>?> performGet() {
    // TODO: implement grab
    throw UnimplementedError();
  }
}
