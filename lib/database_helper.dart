import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Створюємо єдиний екземпляр класу (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skrynia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Створюємо таблицю для ресурсів
    await db.execute('''
      CREATE TABLE resursi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // Метод для додавання запису
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('resursi', row);
  }

  // Метод для читання всіх записів (знадобиться для списку)
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    return await db.query('resursi', orderBy: 'id DESC');
  }
}
