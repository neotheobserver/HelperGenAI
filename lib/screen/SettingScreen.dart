import 'package:HelperGenAI/components/custon_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainScreen.dart';

class SettingScreen extends StatefulWidget {
  final String? initialApiKey;
  final String? selectedLanguage;
  final double? fontSize;
  SettingScreen({this.initialApiKey, this.selectedLanguage, this.fontSize});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  late String _selectedLanguage;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.initialApiKey ?? '';
    _selectedLanguage = widget.selectedLanguage ?? "Nepali";
    _fontSize = widget.fontSize ?? 14;
  }

  void _saveApiKey() async {
    String apiKey = _apiKeyController.text;
    if (apiKey.isNotEmpty && _selectedLanguage.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('apiKey', apiKey);
      prefs.setString('language', _selectedLanguage);
      prefs.setDouble(
          'font', (_fontSize >= 12 || _fontSize <= 24) ? _fontSize : 14);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter API Key')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
              items: ['Nepali', 'English', 'Hindi']
                  .map(
                    (lang) => DropdownMenuItem(
                      value: lang,
                      child: CustomText(
                        text: lang,
                        fontSize: _fontSize,
                      ),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Select Language',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 24,
              label: "Font:${_fontSize.toStringAsFixed(1)}",
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveApiKey,
              child: CustomText(
                text: 'Save and Continue',
                fontSize: _fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
