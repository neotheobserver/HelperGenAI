import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(HelperApp());
}

class HelperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helper Genai',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2E2B3F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3B2A5A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.white70),
          displaySmall: TextStyle(color: Colors.white60),
          headlineLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: Colors.white70),
          headlineSmall: TextStyle(color: Colors.white60),
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white70),
          titleSmall: TextStyle(color: Colors.white60),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
          bodySmall: TextStyle(color: Colors.white38),
          labelLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Colors.white70),
          labelSmall: TextStyle(color: Colors.white60),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A4B8A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3A334D),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadApiKey(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return CameraScreen();
          } else {
            return ApiKeyScreen();
          }
        }
      },
    );
  }

  Future<String?> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiKey');
  }
}

class ApiKeyScreen extends StatefulWidget {
  final String? initialApiKey;
  final String? selectedLanguage;
  ApiKeyScreen({this.initialApiKey, this.selectedLanguage});

  @override
  _ApiKeyScreenState createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.initialApiKey ?? '';
    _selectedLanguage = widget.selectedLanguage ?? "Nepali";
  }

  void _saveApiKey() async {
    String apiKey = _apiKeyController.text;
    if (apiKey.isNotEmpty && _selectedLanguage.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('apiKey', apiKey);
      prefs.setString('language', _selectedLanguage);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen()),
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
                      child: Text(lang),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Select Language',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveApiKey,
              child: const Text('Save and Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<File> _images = [];
  bool loading = false;

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
    setState(() {
      loading = true;
    });

    String? apiKey = await _loadApiKey();
    String? language = await _loadLanguageSelected();
    String response = 'No reponse Recieved...';

    if (apiKey != null && apiKey.isNotEmpty && _images.isNotEmpty) {
      // Prepare the API call
      final model =
          GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      final content = [
        Content.text(
            "Explain in detail the content of the image and what it is trying to potray using $language language"),
        for (final image in _images)
          Content.data(lookupMimeType(image.path) ?? "image/jpg",
              image.readAsBytesSync())
      ];
      final generatedResponse = await model.generateContent(content);
      response = generatedResponse.text?.replaceAll("*", "") ?? response;

      setState(() {
        loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseScreen(response: response),
        ),
      );
    } else if (_images.isEmpty) {
      setState(() {
        loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseScreen(response: response),
        ),
      );
    } else {
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ApiKeyScreen()),
      );
    }
  }

  Future<String?> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiKey');
  }

  Future<String?> _loadLanguageSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language');
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
            icon: Icon(Icons.key),
            onPressed: () async {
              String? currentApiKey = await _loadApiKey();
              String? selectedLanguage = await _loadLanguageSelected();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ApiKeyScreen(
                          initialApiKey: currentApiKey,
                          selectedLanguage: selectedLanguage,
                        )),
              );
            },
          ),
        ],
      ),
      body: loading
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
                if (_images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _makeApiCall,
                      child: const Text('Ask Gemini'),
                    ),
                  ),
              ],
            ),
    );
  }
}

class ResponseScreen extends StatelessWidget {
  final String response;

  ResponseScreen({required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Response')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: Text(response)),
      ),
    );
  }
}
