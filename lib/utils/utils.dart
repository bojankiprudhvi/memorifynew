import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();

  // Pick an image
  final XFile? image = await _picker.pickImage(source: source);

  if (image != null) {
    return await image.readAsBytes();
  }
  print("No image selected");
}
