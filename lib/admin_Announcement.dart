import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AnnouncementSqliteHelper {
  final String sqlFileName = 'announcements.sql';
  final String table = 'announcements';
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
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          imageData BLOB,
          createdAt TEXT
        );
        ''');
      },
    );
  }

  // 插入公告
  Future<int> insertAnnouncement(Map<String, dynamic> announcementData) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.insert(table, announcementData);
  }

  // 查询所有公告
  Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(table, orderBy: 'createdAt DESC');
  }

  // 删除公告
  Future<int> deleteAnnouncement(int announcementId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.delete(
      table,
      where: 'id = ?',
      whereArgs: [announcementId],
    );
  }

  Future<void> close() async {
    await db?.close();
  }
}