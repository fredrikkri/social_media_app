import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageService extends StatelessWidget {
  const UploadImageService({super.key});

  Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      print('mage path: ${imageFile.path}');
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = imageRef.putFile(imageFile);

      uploadTask.snapshotEvents.listen((event) {
        print(
            'Upload progress: ${(event.bytesTransferred / event.totalBytes) * 100}%');
      });

      await uploadTask.whenComplete(() => print('Upload complete'));

      final downloadUrl = await imageRef.getDownloadURL();
      print('Image uploaded successfully. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
