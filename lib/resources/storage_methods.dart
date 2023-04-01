import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Adding image to firebase storage
  Future<String> uploadImageToStorage({
    required String childName,
    required Uint8List file,
    required bool isPost,
  }) async {
    final id = const Uuid().v1();

    // This folder structure is for post and Signup user image
    Reference ref;
    if (isPost == true) {
      ref = _storage
          .ref()
          .child(childName)
          .child(_auth.currentUser!.uid)
          .child(id);
    } else {
      ref = _storage.ref().child(childName).child(_auth.currentUser!.uid);
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot task = await uploadTask;

    String dawnloadUrl = await task.ref.getDownloadURL();

    return dawnloadUrl;
  }
}
