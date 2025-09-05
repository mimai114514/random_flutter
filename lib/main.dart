import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
      ),
      home: const NavigationBase(),
    );
  }
}

class NavigationBase extends StatefulWidget {
  const NavigationBase({super.key});

  @override
  State<NavigationBase> createState() => _NavigationBaseState();
}

class _NavigationBaseState extends State<NavigationBase> {
  var _PageIndex = 0;

  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  var _IsChoosing = false;
  var _ChosenNumber;
  var _MinNumber;
  var _MaxNumber;

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void random() {
    final random = Random();
    if (_MinNumber != null && _MaxNumber != null && _MinNumber < _MaxNumber) {
      setState(() {
        _ChosenNumber =
            _MinNumber + random.nextInt(_MaxNumber - _MinNumber + 1);
      });
    }
    setState(() {
      _IsChoosing = true;
    });
  }

  void confirm() {
    setState(() {
      _IsChoosing = false;
    });
  }

  void onPressed() {
    switch (_IsChoosing) {
      case true:
        confirm();
        break;
      case false:
        random();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_PageIndex) {
      case 0:
        page = HomePage(
          minController: _minController,
          maxController: _maxController,
          isChoosing: _IsChoosing,
          chosenNumber: _ChosenNumber,
          onMinChanged:
              (value) => setState(() {
                _MinNumber = int.tryParse(value);
              }),
          onMaxChanged:
              (value) => setState(() {
                _MaxNumber = int.tryParse(value);
              }),
          onButtonPressed: onPressed,
        );
        break;
      case 1:
        page = SettingsPage();
        break;
      default:
        page = const Center(child: Text('Unknown Page'));
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedIndex: _PageIndex,
        onDestinationSelected: (int index) {
          if (index != _PageIndex) {
            setState(() {
              _PageIndex = index;
            });
          }
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool isChoosing;
  final int? chosenNumber;
  final Function(String) onMinChanged;
  final Function(String) onMaxChanged;
  final VoidCallback onButtonPressed;

  HomePage({
    required this.minController,
    required this.maxController,
    required this.isChoosing,
    required this.chosenNumber,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget numberModePage;
    switch (isChoosing) {
      case true:
        numberModePage = Text(
          chosenNumber.toString(),
          style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        );
        break;
      case false:
        numberModePage = Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: minController,
              decoration: InputDecoration(
                labelText: '最小值',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: onMinChanged,
            ),
            SizedBox(height: 12),
            TextField(
              controller: maxController,
              decoration: InputDecoration(
                labelText: '最大值',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: onMaxChanged,
            ),
          ],
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Random')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(child: numberModePage),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onButtonPressed,
        child: Icon(isChoosing ? Icons.check : Icons.casino),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings Page'));
  }
}
