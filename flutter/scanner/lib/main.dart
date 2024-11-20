import 'package:flutter/material.dart';
import 'package:scanner/scanner_screen.dart';
import 'package:scanner/stafflogin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StaffLoginPage(),
    );
  }
}
