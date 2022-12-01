import 'package:flutter/material.dart';
import 'package:flutter_esp32/set/permission.dart';
import './MainPage.dart';
import 'package:firebase_core/firebase_core.dart';

final Permissionl _permissionl = Permissionl();

Future<void> main() async {
  runApp(new ExampleApplication());
}

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
