import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securenote/screens/pin/pin_lock.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromRGBO(94, 114, 228, 1.0),
    statusBarColor: Color.fromRGBO(94, 114, 228, 1.0),
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Note',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PinLockScreen(),
    );
  }
}
