import 'package:path/path.dart';
import 'package:savek/model/note.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'notes.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)',
        );
      }
    );
  }

  static Future<void> insertNote(Note note) async {
    final db = await database();
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Note>> fetchNotes() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  static Future<void> deleteNote(int id) async {
    final db = await database();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}