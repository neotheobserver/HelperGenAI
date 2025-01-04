import 'package:flutter/material.dart';
import '../components/custon_text.dart';

class ResponseScreen extends StatelessWidget {
  final String response;
  final double fontSize;

  ResponseScreen({required this.response, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Response')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: CustomText(
          text: response,
          fontSize: fontSize,
        )),
      ),
    );
  }
}
