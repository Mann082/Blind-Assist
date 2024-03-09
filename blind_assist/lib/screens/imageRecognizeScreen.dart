import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageRecognizeScreen extends StatefulWidget {
  final String? path;
  const ImageRecognizeScreen({super.key, required this.path});

  @override
  State<ImageRecognizeScreen> createState() => _ImageRecognizeScreenState();
}

class _ImageRecognizeScreenState extends State<ImageRecognizeScreen> {
  bool _isBusy = false;
  var text = "";
  final FlutterTts _flutterTts = FlutterTts();
  List<Map> _voices = [];
  Map? _currentVoice;

  @override
  void initState() {
    final inputImage = InputImage.fromFilePath(widget.path!);
    processImage(inputImage);
    super.initState();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void initTTS() {
    _flutterTts.setProgressHandler((text, start, end, word) {});
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        _voices =
            voices.where((voice) => voice["name"].contains("en")).toList();
        _currentVoice = _voices.first;
        setVoice(_currentVoice!);
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recongnized Text"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
          stops: [0, 1, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: _isBusy == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      text,
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ))),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              showToast("Stopped Playing");
              _flutterTts.stop();
            },
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: Icon(
                Icons.pause,
                size: 40,
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: () {
              showToast("Playing");
              _flutterTts.speak(text);
            },
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: Icon(
                Icons.play_arrow,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void processImage(InputImage image) async {
    setState(() {
      _isBusy = true;
    });
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);
    text = recognizedText.text;
    setState(() {
      _isBusy = false;
    });
  }
}
