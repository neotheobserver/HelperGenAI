import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../components/custon_text.dart';

class ResponseScreen extends StatefulWidget {
  final String response;
  final double fontSize;
  final String localeId;

  ResponseScreen(
      {required this.response, required this.fontSize, required this.localeId});

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  bool _isNotSpeaking = true;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage(widget.localeId.replaceAll("_", "-"));
  }

  Future _startSpeaking() async {
    setState(() {
      _isNotSpeaking = false;
    });
    await flutterTts.speak(widget.response);
  }

  Future _stopSpeaking() async {
    setState(() {
      _isNotSpeaking = true;
    });
    await flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Response')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: CustomText(
            text: widget.response,
            fontSize: widget.fontSize,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isNotSpeaking ? _startSpeaking : _stopSpeaking,
        tooltip: 'Listen',
        child: Icon(
            _isNotSpeaking ? Icons.speaker_notes_off : Icons.speaker_notes),
      ),
    );
  }
}
