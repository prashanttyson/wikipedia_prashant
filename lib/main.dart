import 'package:flutter/material.dart';


import './pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WikiPedia',
          theme: new ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: new PagesHome(),
        );
  }

}
