import 'dart:io';

import 'package:HelperGenAI/screen/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'ResponseScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _questionController = TextEditingController();
  List<File> _images = [];
  bool _loading = true;
  late String _currentApiKey;
  late String _currentLanguage;
  late double _currentFontSize;
  SpeechToText _speechToText = SpeechToText();
  String _localeId = 'en_US';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _initSpeech() async {
    // nned further work here
    await _speechToText.initialize();
    List<String> priorities = [];
    if (_currentLanguage == 'Nepali') {
      priorities = ['ne', 'hi', 'en'];
    } else if (_currentLanguage == 'Hindi') {
      priorities = ['hi', 'en'];
    } else {
      priorities = ['en'];
    }
    List<LocaleName> locales = await _speechToText.locales();

    if (locales.isNotEmpty) {
      LocaleName? selectedLocale;
      for (String priority in priorities) {
        selectedLocale = locales.firstWhere(
          (locale) => locale.localeId.startsWith(priority),
          orElse: () => locales.first, //This is not a good idea
        );
        if (selectedLocale.localeId.startsWith(priority)) break;
      }

      //This should never happen
      if (selectedLocale != null) {
        _localeId = selectedLocale.localeId;
      } else {
        _localeId = 'en_US'; // Default fallback
      }
    }

    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
        localeId: _localeId,
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 20));
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _questionController.text = result.recognizedWords;
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentApiKey = prefs.getString('apiKey') ?? '';
    _currentLanguage = prefs.getString('language') ?? 'Nepali';
    _currentFontSize = prefs.getDouble('font') ?? 14;
    _initSpeech();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  //Maybe can refactor this logic later
  Future<void> _makeApiCall() async {
    final String controllerText = _questionController.text;
    if (_images.isNotEmpty ||
        (controllerText.isNotEmpty && controllerText.split(" ").length > 2)) {
      setState(() {
        _loading = true;
      });
      // Prepare the API call
      final model = GenerativeModel(
          model: 'gemini-1.5-flash-latest', apiKey: _currentApiKey);
      final String question = controllerText.isNotEmpty &&
              controllerText.split(" ").length > 2
          ? "In lanugage $_currentLanguage answer: $controllerText"
          : "Explain in detail the content of the image and what it is trying to potray using $_currentLanguage language";
      final content = [
        Content.text(question),
        for (final image in _images)
          Content.data(lookupMimeType(image.path) ?? "image/jpg",
              image.readAsBytesSync())
      ];
      String? response;
      try {
        final generatedResponse = await model
            .generateContent(content)
            .onError((e, s) => GenerateContentResponse(
                  [],
                  PromptFeedback(null, e.toString(), []),
                ));
        response = generatedResponse.text?.replaceAll("*", "");
        response = response == null || response.isEmpty
            ? 'No reponse Recieved...'
            : response;
      } catch (e) {
        response = e.toString();
      }

      setState(() {
        _loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseScreen(
              response: response!,
              fontSize: _currentFontSize,
              localeId: _localeId),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helper Genai'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingScreen(
                          initialApiKey: _currentApiKey,
                          selectedLanguage: _currentLanguage,
                          fontSize: _currentFontSize,
                        )),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_images.isNotEmpty)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Image.file(
                              _images[index],
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 5,
                              top: 5,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('No image selected'),
                    ),
                  ),
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _openCamera,
                      child: const Text('Open Camera'),
                    ),
                    ElevatedButton(
                      onPressed: _selectImage,
                      child: const Text('Select Images'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _makeApiCall,
                    child: const Text('Ask Gemini'),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
