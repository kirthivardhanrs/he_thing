import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

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
  Database? _database;
  List<MenuItem> _menuItems = [];

  @override
  void initState() {
    super.initState();
    openDatabaseAndLoadItems();
  }

  Future<void> openDatabaseAndLoadItems() async {
    _database = await openDatabase(
      'menu_database.db',
      version: 1,
      onCreate: (Database db, int version) {
        db.execute(
          'CREATE TABLE menu_items (id INTEGER PRIMARY KEY, name TEXT, price REAL)',
        );
      },
    );
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    final List<Map<String, dynamic>> maps =
        await _database!.query('menu_items');
    setState(() {
      _menuItems = List.generate(maps.length, (i) {
        return MenuItem(
          id: maps[i]['id'],
          name: maps[i]['name'],
          price: maps[i]['price'],
        );
      });
    });
  }

  Future<void> addMenuItem(String name, double price) async {
    final menuItem = MenuItem(name: name, price: price);
    await _database!.insert(
      'menu_items',
      menuItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    loadMenuItems();
  }

  Future<void> updateMenuItem(MenuItem menuItem) async {
    await _database!.update(
      'menu_items',
      menuItem.toMap(),
      where: 'id = ?',
      whereArgs: [menuItem.id],
    );
    loadMenuItems();
  }

  Future<void> deleteMenuItem(int id) async {
    await _database!.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    loadMenuItems();
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
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteMenuItem(menuItem.id!),
            ),
            onTap: () => speak(menuItem.name),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String name = '';
              double price = 0.0;

              return AlertDialog(
                title: Text('Add Menu Item'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        name = value;
                      },
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      onChanged: (value) {
                        price = double.tryParse(value) ?? 0.0;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Price'),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      addMenuItem(name, price);
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
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
        child: Icon(Icons.add),
      ),
    );
  }
}

class MenuItem {
  final int? id;
  final String name;
  final double price;

  MenuItem({this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price};
  }
}
