import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class UserFeedbackSqliteHelper {
  final String sqlFileName = 'user_feedback.sql';
  final String table = 'user_feedback';
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
          userId INTEGER,
          feedbackContent TEXT,
          feedbackTime TEXT,
          isResolved BOOLEAN DEFAULT 0
        );
        ''');
      },
    );
  }

  // 插入用户反馈
  Future<int> insertFeedback(Map<String, dynamic> feedbackData) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.insert(table, feedbackData);
  }

  // 查询所有反馈
  Future<List<Map<String, dynamic>>> getAllFeedbacks() async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(table, orderBy: 'feedbackTime DESC');
  }

  // 更新反馈解决状态
  Future<int> updateFeedbackStatus(int feedbackId, bool isResolved) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.update(
      table,
      {'isResolved': isResolved ? 1 : 0},
      where: 'id = ?',
      whereArgs: [feedbackId],
    );
  }

  Future<void> close() async {
    await db?.close();
  }
}