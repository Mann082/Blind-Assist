import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  User? _user;
  List<Map> _voices = [];
  Map? _currentVoice;

  @override
  void initState() {
    super.initState();
    initTTS();
    _user = FirebaseAuth.instance.currentUser;
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
        log(e.toString());
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  var history = [];
  Future<void> fetchHistory() async {
    var cpyList = history;
    String endpoint =
        "https://blind-assist-66d0d-default-rtdb.asia-southeast1.firebasedatabase.app/history/${_user!.uid}.json";
    history = [];
    try {
      final url = Uri.parse(endpoint);
      var response = await http.get(url);
      var resData = jsonDecode(response.body);
      log(resData);
      resData.forEach((key, value) {
        history.add(value);
      });
      history = history.reversed.toList();

      log(history.toString());
    } catch (err) {
      history = cpyList;
      log(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
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
        child: Center(
          child: FutureBuilder(
            future: fetchHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (history.isEmpty) {
                  return const Text("No History Found");
                } else {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      // var (key, value) = history[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              tileColor: Colors.white,
                              textColor: Colors.white,
                              title:
                                  Text(history[index].values.first.toString()),
                              subtitle: Text(
                                  "barcode:- ${history[index].keys.first.toString()}"),
                              trailing: IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  child: Icon(
                                    Icons.play_arrow,
                                  ),
                                ),
                                onPressed: () {
                                  _flutterTts.speak(
                                      history[index].values.first.toString());
                                },
                              ),
                            ),
                            const Divider(
                              height: 1,
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: history.length,
                  );
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
