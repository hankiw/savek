import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:savek/model/memo.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'memo_app.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE memo(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            amount INTEGER,
            content TEXT
          )
        ''');
      }
    );
  }

  static Future<int> insertMemo(Memo memo) async {
    final db = await database();
    return await db.insert('memo', memo.toMap());
  }

  static Future<List<Memo>> loadMemo(String searchYM) async {
    
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query(
      'memo',
      where: 'date LIKE ?',
      whereArgs: ['${searchYM}%'],
      orderBy: 'date DESC'
    );
    return List.generate(
      maps.length,
      (i) => Memo.fromMap(maps[i])
    );
  }

  static Future<void> deleteMemo(int id) async {
    if (id < 0) return;
    
    final db = await database();
    await db.delete('memo', where: 'id = ?', whereArgs: [id]);
  }
}