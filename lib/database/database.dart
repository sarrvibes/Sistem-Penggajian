import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// import 'dart:io';
import '../models/karyawan.dart';

class DatabaseKaryawan {
  static final DatabaseKaryawan instance = DatabaseKaryawan._init();
  static Database? _database;

  DatabaseKaryawan._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('payroll.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);
    return await openDatabase(path,
        version: 1,
        onCreate: _createDB,
        onConfigure: (db) async {
          // enable foreign keys if needed
          await db.execute('PRAGMA foreign_keys = ON');
        });
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        baseSalary REAL NOT NULL,
        allowance REAL NOT NULL,
        deduction REAL NOT NULL,
        totalSalary REAL NOT NULL
      )
    ''');
  }

  Future<Karyawan> createKaryawan(Karyawan emp) async {
    final db = await instance.database;
    final id = await db.insert('karyawan', emp.toMap());
    emp.id = id;
    return emp;
  }

  Future<List<Karyawan>> readAllKaryawan() async {
    final db = await instance.database;
    final result = await db.query('karyawan', orderBy: 'id DESC');
    return result.map((json) => Karyawan.fromMap(json)).toList();
  }

  Future<int> updateKaryawan(Karyawan emp) async {
    final db = await instance.database;
    return db.update('karyawan', emp.toMap(), where: 'id = ?', whereArgs: [emp.id]);
  }

  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return await db.delete('karyawan', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
