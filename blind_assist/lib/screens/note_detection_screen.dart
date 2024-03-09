import 'package:flutter/material.dart';

class NoteDetectionScreen extends StatelessWidget {
  const NoteDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Note Detection"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
            stops: [0, 0.8, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
          width: double.infinity,
          height: double.infinity,
          child: const Center(
            child: Text(
              "Coming Soon!",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
        ));
  }
}
