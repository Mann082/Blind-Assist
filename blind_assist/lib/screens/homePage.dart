import 'dart:convert';
import 'dart:developer';

import 'package:blind_assist/screens/history.dart';
import 'package:blind_assist/screens/imageRecognizeScreen.dart';
import 'package:blind_assist/screens/note_detection_screen.dart';
import 'package:blind_assist/screens/scanResultScreen.dart';
import 'package:blind_assist/utils/image_cropper_page.dart';
import 'package:blind_assist/utils/image_picker_class.dart';
import 'package:blind_assist/widgets/modal_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String? _scannedBarcode;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    _scannedBarcode = barcodeScanRes;
    if (_scannedBarcode == "-1") return;
    try {
      String endpoint =
          "https://blind-assist-66d0d-default-rtdb.asia-southeast1.firebasedatabase.app/barcodes.json";
      final url = Uri.parse(endpoint);
      final response = await http.get(url);
      Map<String, dynamic> resbody = jsonDecode(response.body);
      print(_scannedBarcode);
      print(resbody.containsKey(_scannedBarcode));
      print(resbody[_scannedBarcode]);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ScannedResultScreen(
            result: resbody.containsKey(_scannedBarcode)
                ? resbody[_scannedBarcode]
                : "Product Not Found in Database",
            scannedCode: _scannedBarcode ?? "Code Not Identified"),
      ));
    } catch (err) {
      print(err);
    }
    setState(() {
      print(_scannedBarcode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blind Assist"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xff091e3a),
                  Color(0xff2f80ed),
                  Color(0xff2d9ee0)
                ],
                stops: [0, 1, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
              child: Center(
                  child: Text(
                "Hello ${_user!.displayName}",
                style: const TextStyle(fontSize: 30, color: Colors.white),
              )),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ));
                },
                child: const ListTile(
                  leading: Icon(Icons.history),
                  title: Text("History"),
                )),
            const Divider(
              height: 1,
            ),
            TextButton(
                onPressed: () async {
                  await GoogleSignIn().signOut();
                  _auth.signOut();
                },
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                )),
            const Divider(
              height: 1,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
          stops: [0, 0.8, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: scanBarcodeNormal,
                  child: Card(
                    elevation: 10,
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffece9e6), Color(0xffffffff)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Start Scanning",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return NoteDetectionScreen();
                      },
                    ));
                  },
                  child: Card(
                    elevation: 10,
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffece9e6), Color(0xffffffff)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Note Detection",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () => imagePickerModal(
                    context,
                    onCameraTap: () {
                      log("camera");
                      pickImage(source: ImageSource.camera).then((value) {
                        imageCropperView(value, context).then((value) => {
                              if (value != "")
                                {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return ImageRecognizeScreen(path: value);
                                    },
                                  ))
                                }
                            });
                      });
                    },
                    onGalleryTap: () {
                      log("gallery");
                      pickImage(source: ImageSource.gallery).then((value) {
                        imageCropperView(value, context).then((value) => {
                              if (value != "")
                                {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return ImageRecognizeScreen(path: value);
                                    },
                                  ))
                                }
                            });
                      });
                    },
                  ),
                  child: Card(
                    elevation: 10,
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffece9e6), Color(0xffffffff)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Document Reading",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
