import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'flight.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flights.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE flights (
  id $idType,
  departureCity $textType,
  destinationCity $textType,
  departureTime $textType,
  arrivalTime $textType
  )
''');
  }

  Future<Flight> create(Flight flight) async {
    final db = await instance.database;
    final id = await db.insert('flights', flight.toMap());
    return flight.copyWith(id: id);
  }

  Future<Flight> readFlight(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'flights',
      columns: ['id', 'departureCity', 'destinationCity', 'departureTime', 'arrivalTime'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Flight.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Flight>> readAllFlights() async {
    final db = await instance.database;
    final result = await db.query('flights');
    return result.map((json) => Flight.fromMap(json)).toList();
  }

  Future<int> update(Flight flight) async {
    final db = await instance.database;
    return db.update(
      'flights',
      flight.toMap(),
      where: 'id = ?',
      whereArgs: [flight.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'flights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
