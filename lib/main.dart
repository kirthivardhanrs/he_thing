import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

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
  String? recognizedText;

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
      recognizedText = await FlutterTesseractOcr.extractText(image.path);
      print('Recognized Text: $recognizedText');

      // Process the recognized text and add it to the menu items
      if (recognizedText != null && recognizedText!.isNotEmpty) {
        final menuItemsList = recognizedText!.split('\n');
        for (final menuItemText in menuItemsList) {
          final menuItem = parseMenuItem(menuItemText);
          if (menuItem != null) {
            _menuItems.add(menuItem);
          }
        }
      }

      setState(() {});
    }
  }

  MenuItem? parseMenuItem(String menuItemText) {
    // Parse the menuItemText and extract the name and price
    // Implement your parsing logic here based on the structure of the recognized text

    // Sample parsing logic (assuming the name and price are separated by a comma)
    final parts = menuItemText.split(',');
    if (parts.length == 2) {
      final name = parts[0].trim();
      final price = double.tryParse(parts[1].trim());
      if (name.isNotEmpty && price != null) {
        return MenuItem(name: name, price: price);
      }
    }

    return null;
  }

  void readMenuItem(MenuItem menuItem) {
    final String textToSpeak =
        '${menuItem.name}, Price: \$${menuItem.price.toStringAsFixed(2)}';
    speak(textToSpeak);
  }

  void readMenuItems() {
    final StringBuffer buffer = StringBuffer();

    for (final menuItem in _menuItems) {
      buffer.writeln(
          '${menuItem.name}, Price: \$${menuItem.price.toStringAsFixed(2)}');
    }

    final String textToSpeak = buffer.toString();
    speak(textToSpeak);
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
            onTap: () => readMenuItem(menuItem),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: readMenuItems,
            child: Icon(Icons.mic),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: capturePhoto,
            child: Icon(Icons.camera_alt),
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
