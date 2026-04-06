import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CommentSqliteHelper {
  final String sqlFileName = 'comments.sql';
  final String table = 'comments';
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
          postId INTEGER,
          userId INTEGER,
          content TEXT,
          createdAt TEXT
        );
        ''');
      },
    );
  }

  // 插入评论
  Future<int> insertComment(Map<String, dynamic> commentData) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.insert(table, commentData);
  }

  // 获取帖子的所有评论
  Future<List<Map<String, dynamic>>> getCommentsByPostId(int postId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'createdAt DESC',
    );
  }

  // 删除评论
  Future<int> deleteComment(int commentId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.delete(
      table,
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  // 获取用户的评论
  Future<List<Map<String, dynamic>>> getCommentsByUserId(int userId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  // 删除帖子的所有评论
  Future<int> deleteCommentsByPostId(int postId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.delete(
      table,
      where: 'postId = ?',
      whereArgs: [postId],
    );
  }

  Future<void> close() async {
    await db?.close();
  }
}