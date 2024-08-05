import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'airplane.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('airplanes.db');
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
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE airplanes (
  id $idType,
  type $textType,
  numberOfPassengers $intType,
  maxSpeed $intType,
  range $intType
  )
''');
  }

  Future<Airplane> create(Airplane airplane) async {
    final db = await instance.database;

    final id = await db.insert('airplanes', airplane.toMap());
    return airplane.copyWith(id: id);
  }

  Future<Airplane> readAirplane(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'airplanes',
      columns: ['id', 'type', 'numberOfPassengers', 'maxSpeed', 'range'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Airplane.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Airplane>> readAllAirplanes() async {
    final db = await instance.database;

    final result = await db.query('airplanes');

    return result.map((json) => Airplane.fromMap(json)).toList();
  }

  Future<int> update(Airplane airplane) async {
    final db = await instance.database;

    return db.update(
      'airplanes',
      airplane.toMap(),
      where: 'id = ?',
      whereArgs: [airplane.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'airplanes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
