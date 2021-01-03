import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stats/screens/stats_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FlutterStatsApp();
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class FlutterStatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stats App',
      theme: ThemeData(
        primaryColor: Color(0xFF193484),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StatsScreen(),
    );
  }
}
