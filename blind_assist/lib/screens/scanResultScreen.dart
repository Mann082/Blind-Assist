import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class ScannedResultScreen extends StatefulWidget {
  final String result;
  final String scannedCode;
  const ScannedResultScreen(
      {super.key, required this.result, required this.scannedCode});

  @override
  State<ScannedResultScreen> createState() => _ScannedResultScreenState();
}

class _ScannedResultScreenState extends State<ScannedResultScreen> {
  FlutterTts _flutterTts = FlutterTts();
  User? _user;
  List<Map> _voices = [];
  Map? _currentVoice;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    initTTS();
  }

  void initTTS() {
    _flutterTts.setProgressHandler((text, start, end, word) {});
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        setState(() {
          _voices =
              voices.where((voice) => voice["name"].contains("en")).toList();
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
        _flutterTts.speak(widget.result);
        if (widget.result != "Product Not Found in Database") postResult();
      } catch (e) {
        print(e);
      }
    });
  }

  void postResult() async {
    String endpoint =
        "https://blind-assist-66d0d-default-rtdb.asia-southeast1.firebasedatabase.app/history/${_user!.uid}.json";
    try {
      final url = Uri.parse(endpoint);
      Map<String, String> data = {widget.scannedCode: widget.result};
      var response = await http.post(url, body: jsonEncode(data));
      var resData = jsonDecode(response.body);
      log(resData);
    } catch (err) {
      log(err.toString());
    }
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanned Result"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
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
              Text(
                widget.result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
              Text(
                "Code:- ${widget.scannedCode}",
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _flutterTts.speak(widget.result);
        },
        child: const Icon(
          Icons.speaker_phone,
        ),
      ),
    );
  }
}
