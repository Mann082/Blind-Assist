import 'package:flutter/material.dart';

void imagePickerModal(BuildContext context,
    {VoidCallback? onCameraTap, VoidCallback? onGalleryTap}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
          stops: [0, 1, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        height: 235,
        child: Column(
          children: [
            GestureDetector(
              onTap: onCameraTap,
              child: Card(
                elevation: 10,
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: const Text(
                    "Camera",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onGalleryTap,
              child: Card(
                elevation: 10,
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: const Text(
                    "Gallery",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
