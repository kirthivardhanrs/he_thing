import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
      floatingActionButton: FloatingActionButton(
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
    );
  }
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});
}
