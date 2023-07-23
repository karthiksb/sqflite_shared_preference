import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_flutter/Models/Note.dart';

class DatabaseHelper {
  Future<Database> initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'notes.db');
    var database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return database;
  }

  void _onCreate(Database db, int version) async {
    print('on create');
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  Future<int> insert(Note note) async {
    var dbClient = await initDatabase();
    return await dbClient.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    var dbClient = await initDatabase();
    var result = await dbClient.query('notes', orderBy: 'id DESC',);
    return result.map((noteMap) => Note.fromMap(noteMap)).toList();
  }

  Future<int> delete(int id) async {
    var dbClient = await initDatabase();
    return await dbClient.delete('notes', where: 'id= ?',whereArgs: [id]);
  }
}
