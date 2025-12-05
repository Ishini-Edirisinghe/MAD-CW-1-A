import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/health_records.dart';

class DatabaseHandler {
  // Singleton instance
  static final DatabaseHandler instance = DatabaseHandler._init();
  static Database? _database;

  DatabaseHandler._init();

  // Table Name
  static const String tableHealth = 'health_records';

  // Getter for DB
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_records.db');
    return _database!;
  }

  // Initialize DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create Tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHealth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');
  }

  // INSERT Record
  Future<int> insertRecord(HealthRecord record) async {
    final db = await database;
    return await db.insert(
      tableHealth,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // FETCH all records
  Future<List<HealthRecord>> getRecords() async {
    final db = await database;
    final result = await db.query(tableHealth, orderBy: "id DESC");
    return result.map((e) => HealthRecord.fromMap(e)).toList();
  }

  // FETCH by ID
  Future<HealthRecord?> getRecordById(int id) async {
    final db = await database;

    final result = await db.query(
      tableHealth,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return HealthRecord.fromMap(result.first);
    }
    return null;
  }

  // UPDATE a record
  Future<int> updateRecord(HealthRecord record) async {
    final db = await database;
    return await db.update(
      tableHealth,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // DELETE a record
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(tableHealth, where: 'id = ?', whereArgs: [id]);
  }

  // NEW → GET LAST 7 DAYS RECORDS
  Future<List<HealthRecord>> getLast7DaysRecords() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM $tableHealth 
      ORDER BY date DESC
      LIMIT 7
    ''');

    // Convert map → model
    return result
        .map((e) => HealthRecord.fromMap(e))
        .toList()
        .reversed
        .toList();
  }

  // CLOSE Database
  Future close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
