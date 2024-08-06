import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'flight_list_page.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlightListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
