import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_base.dart';
import 'settings_page.dart';
import 'providers/list_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListProvider(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: NavigationBase(),
        routes: {
          '/settings': (context) => SettingsPage(),
        },
      ),
    );
  }
}
