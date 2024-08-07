import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'dart:io';
import 'app_localizations.dart';
import 'reservation_page.dart';

class ReservationApp extends StatefulWidget {
  final Database database;

  ReservationApp({required this.database});

  @override
  _ReservationAppState createState() => _ReservationAppState();
}

class _ReservationAppState extends State<ReservationApp> {
  Locale _locale = Locale('en');

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airline Reservation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
      ],
      home: ReservationPage(
        database: widget.database,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

Future<Database> openDatabase() async {
  DatabaseFactory factory;

  if (kIsWeb) {
    factory = databaseFactoryWeb;
    final dbPath = 'app_database.db';
    return factory.openDatabase(dbPath);
  } else {
    factory = databaseFactoryIo;
    final dbPath = await _getDatabasePath();
    print("Database path for desktop: $dbPath");
    return factory.openDatabase(dbPath);
  }
}

Future<String> _getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  final dbPath = '${directory.path}\ app_database.db';

  final dbDirectory = Directory(directory.path);
  if (!await dbDirectory.exists()) {
    await dbDirectory.create(recursive: true);
  }

  final dbFile = File(dbPath);
  if (!await dbFile.exists()) {
    await dbFile.create(recursive: true);
  }

  return dbPath;
}
