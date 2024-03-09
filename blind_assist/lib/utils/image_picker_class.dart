import 'dart:developer';

import 'package:image_picker/image_picker.dart';

Future<String> pickImage({ImageSource? source}) async {
  final picker = ImagePicker();
  String path = "";
  try {
    final getImage =
        await picker.pickImage(source: source ?? ImageSource.camera);
    if (getImage != null) {
      path = getImage.path;
    } else {
      path = "";
    }
  } catch (errr) {
    log(errr.toString());
  }
  return path;
}
