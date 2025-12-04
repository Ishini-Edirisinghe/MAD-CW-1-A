import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/health_records.dart';

class DatabaseHandler {
  static final DatabaseHandler instance = DatabaseHandler._init();
  static Database? _database;

  DatabaseHandler._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');
  }

  // Insert Record
  Future<int> insertRecord(HealthRecord record) async {
    final db = await instance.database;
    return await db.insert('health_records', record.toMap());
  }

  // Fetch All
  Future<List<HealthRecord>> getRecords() async {
    final db = await instance.database;
    final result = await db.query('health_records', orderBy: "id DESC");
    return result.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // Get By ID
  Future<HealthRecord?> getRecordById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return HealthRecord.fromMap(result.first);
    }
    return null;
  }

  // Update Record
  Future<int> updateRecord(HealthRecord record) async {
    final db = await instance.database;
    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete Record
  Future<int> deleteRecord(int id) async {
    final db = await instance.database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // Close DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
