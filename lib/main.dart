import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import 'ocr_service.dart';

void main() {
  runApp(MenuApp());
}

class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();
  List<MenuItem> _menuItems = [];
  OCRService _ocrService = OCRService();

  @override
  void initState() {
    super.initState();
    loadMenuItems();
  }

  void loadMenuItems() {
    // Simulating loading menu items from a data source
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _menuItems = [
          MenuItem(name: 'Item 1', price: 9.99),
          MenuItem(name: 'Item 2', price: 12.99),
          MenuItem(name: 'Item 3', price: 15.99),
          MenuItem(name: 'Item 4', price: 8.99),
        ];
      });
    });
  }

  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  void capturePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final recognizedText = await _ocrService.recognizeText(File(image.path));
      print('Recognized Text: $recognizedText');
      // Further process the recognized text as per your requirements
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu App'),
      ),
      body: ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final menuItem = _menuItems[index];
          return ListTile(
            title: Text(menuItem.name),
            subtitle: Text('\$${menuItem.price.toStringAsFixed(2)}'),
            onTap: () => speak(menuItem.name),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: capturePhoto,
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String textToSpeak = '';

                  return AlertDialog(
                    title: Text('Text-to-Speech'),
                    content: TextField(
                      onChanged: (value) {
                        textToSpeak = value;
                      },
                      decoration: InputDecoration(labelText: 'Text'),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          speak(textToSpeak);
                          Navigator.pop(context);
                        },
                        child: Text('Speak'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.record_voice_over),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});
}
