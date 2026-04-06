import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class SqliteHelper {
  final String sqlFileName = 'myd.sql';
  final String table = 'userpost';
  Database? db;

  Future<void> open() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, sqlFileName);

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $table(
          id INTEGER PRIMARY KEY,
          userId INTEGER,
          userPassword TEXT,
          email TEXT,
          name TEXT,
          avatarData BLOB,
          backgroundData BLOB,
        );
        ''');
      },
    );
  }

  Future<int> insert(Map<String, dynamic> data) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(table);
  }

  Future<Map<String, dynamic>?> queryUserById(int userId) async {
    if (db == null || !db!.isOpen) await open();
    final results = await db!.query(
      table,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> delete(int id) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.delete(
      table,
      where: 'userId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUser(Map<String, dynamic> data) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.update(
      table,
      data,
      where: 'userId = ?',
      whereArgs: [data['userId']],
    );
  }

  Future<int> updateUserImages(int userId, List<int>? avatarData, List<int>? backgroundData) async {
    if (db == null || !db!.isOpen) await open();

    final data = <String, dynamic>{};
    if (avatarData != null) {
      data['avatarData'] = avatarData;
    }
    if (backgroundData != null) {
      data['backgroundData'] = backgroundData;
    }

    if (data.isEmpty) return 0;

    return await db!.update(
      table,
      data,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> close() async {
    await db?.close();
  }
}