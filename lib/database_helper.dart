
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'skrynia.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE resources(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        count INTEGER NOT NULL
      )
    ''');
  }

  // Метод для додавання нового ресурсу
  Future<int> insertResource(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('resources', row);
  }

  // Метод для отримання всіх ресурсів
  Future<List<Map<String, dynamic>>> queryAllResources() async {
    final db = await database;
    return await db.query('resources', orderBy: 'name');
  }
  
  // Метод для оновлення ресурсу
  Future<int> updateResource(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update('resources', row, where: 'id = ?', whereArgs: [id]);
  }

  // Метод для видалення ресурсу
  Future<int> deleteResource(int id) async {
    final db = await database;
    return await db.delete('resources', where: 'id = ?', whereArgs: [id]);
  }
}
