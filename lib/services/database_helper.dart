import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import 'package:securenote/models/noteModel.dart';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static const String databaseName = 'database.db';
  static const int versionNumber = 1;

  static const String tableNotes = 'Notes';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colIsArchived = 'isArchived';
  static const String colIsPinned = 'isPinned';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);

    var db = await openDatabase(path, version: versionNumber, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE IF NOT EXISTS $tableNotes ("
        " $colId INTEGER PRIMARY KEY AUTOINCREMENT, "
        " $colTitle TEXT NOT NULL, "
        " $colDescription TEXT,"
        " $colIsArchived INTEGER NOT NULL DEFAULT 0,"
        " $colIsPinned INTEGER NOT NULL DEFAULT 0"
        ")");
  }

  Future<List<NoteModel>> getAll({bool archived = false}) async {
    final db = await database;
    final result = await db.query(
      tableNotes,
      where: '$colIsArchived = ?',
      whereArgs: [archived ? 1 : 0],
      orderBy: '$colIsPinned DESC, $colId ASC',
    );
    return result.map((json) => NoteModel.fromJson(json)).toList();
  }

  Future<NoteModel> read(int id) async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      where: '$colId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NoteModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<void> insert(NoteModel note) async {
    final db = await database;
    await db.insert(tableNotes, note.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(NoteModel note) async {
    final db = await database;
    var res = await db.update(tableNotes, note.toJson(), where: '$colId = ?', whereArgs: [note.id]);
    return res;
  }

  Future<void> delete(int id) async {
    final db = await database;
    try {
      await db.delete(tableNotes, where: "$colId = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}