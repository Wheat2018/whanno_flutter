import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whanno_flutter/models/images_viewer.dart';
import 'package:whanno_flutter/models/labels_viewer.dart';
import 'package:whanno_flutter/models/mapping.dart';
import 'package:whanno_flutter/utils/extension_utils.dart';

class GalleryModel extends ChangeNotifier {
  GalleryModel() {
    var images = imagesGetterTest();
    var labels = singleLabelsTextViewerTest();
    labels.append(init: labels[0]?.str ?? "");
    labels.append(init: labels[0]?.str ?? "");
    labels.append(init: labels[0]?.str ?? "");
    labels.append(init: labels[0]?.str ?? "");
    var it1 = Iterable.generate(images.get()?.length ?? 0).iterator,
        it2 = Iterable.generate(labels.get()?.length ?? 0).iterator;
    _signedImages = mapping(
        images: images.get()!,
        labels: labels.skipNull(),
        imageKey: (_) => (it1..moveNext()).current.toString(),
        labelKey: (_, __) => (it2..moveNext()).current.toString());
  }
  late Map<String, SignedImage> _signedImages;
  int _index = 0;

  UnmodifiableListView<SignedImage> get imageUrls => UnmodifiableListView(_signedImages.values);
  int get index => _index;
  SignedImage get current => imageUrls[index];

  void select(int index) {
    if (index >= 0 && index < imageUrls.length) {
      this._index = index;
      notifyListeners();
    }
  }

  static GalleryModel of(BuildContext context, {bool listen = true}) => Provider.of(context, listen: listen);
}
