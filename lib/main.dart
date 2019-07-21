import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = List<Item>();
  HomePage() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Banana", done: true));
    // items.add(Item(title: "Maçã", done: true));
    // items.add(Item(title: "Abacate", done: false));
    // items.add(Item(title: "Uva", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = new TextEditingController();

  _HomePageState() {
    load();
  }

  void add() {
    if (newTaskController.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskController.text, done: false));
      newTaskController.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decode = jsonDecode(data);
      List<Item> result = decode.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          var item = widget.items[index];
          return Dismissible(
            onDismissed: (direction) {
              remove(index);
            },
            background: Container(
              color: Colors.red,
            ),
            key: Key(item.title),
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: add,
        child: Icon(Icons.add),
      ),
    );
  }
}
