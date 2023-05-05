import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({Key? key}) : super(key: key);

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(
        () => {
          this.image = imageTemp,
          Navigator.pop(context),
        },
      );
    } on PlatformException {
      debugPrint("failed to pick image: $image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            widthFactor: 1,
            child: Text(
              "Fotoğraf Seçin",
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  pickImage(ImageSource.camera);
                  //Kamerayı aç
                  debugPrint("Kamera");
                },
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 100,
                ),
              ),
              const SizedBox(width: 25),
              GestureDetector(
                onTap: () {
                  //galeriyi aç
                  pickImage(ImageSource.gallery);
                  debugPrint("Galeri");
                },
                child: const Icon(
                  Icons.photo_album_rounded,
                  size: 100,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
