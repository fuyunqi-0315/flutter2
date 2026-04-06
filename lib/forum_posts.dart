import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ForumPostSqliteHelper {
  final String sqlFileName = 'forum_posts.sql';
  final String table = 'posts';
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
          authorId INTEGER,
          createdAt TEXT,
          imageData BLOB,
          likes INTEGER DEFAULT 0,
          zoneType TEXT DEFAULT 'other',
          isApproved BOOLEAN DEFAULT 0
        );
        ''');
      },
    );
  }

  Future<int> insertPost(Map<String, dynamic> postData) async {
    if (db == null || !db!.isOpen) await open();

    final data = Map<String, dynamic>.from(postData);
    if (!data.containsKey('isApproved')) {
      data['isApproved'] = 0;
    }

    return await db!.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(table, orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getApprovedPosts() async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'isApproved = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPendingPosts() async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'isApproved = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPostsByZone(String zoneType) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'zoneType = ? AND isApproved = ?',
      whereArgs: [zoneType, 1],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPostsByAuthor(int authorId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'authorId = ?',
      whereArgs: [authorId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getApprovedPostsByAuthor(int authorId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'authorId = ? AND isApproved = ?',
      whereArgs: [authorId, 1],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> updatePostApproval(int postId, bool isApproved) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.update(
      table,
      {'isApproved': isApproved ? 1 : 0},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<int> batchApprovePosts(List<int> postIds) async {
    if (db == null || !db!.isOpen) await open();

    int count = 0;
    for (int postId in postIds) {
      final result = await updatePostApproval(postId, true);
      count += result;
    }
    return count;
  }

  Future<int> updatePost(int postId, Map<String, dynamic> updatedData) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.update(
      table,
      updatedData,
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<int> deletePost(int postId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.delete(
      table,
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<int> deletePostByTitle(String title) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.delete(
      table,
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  Future<List<Map<String, dynamic>>> getPostsByTitle(String title) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'title LIKE ? AND isApproved = ?',
      whereArgs: ['%$title%', 1],
      orderBy: 'createdAt DESC',
    );
  }

  Future<dynamic> getPostImage(int postId) async {
    if (db == null || !db!.isOpen) await open();
    final result = await db!.query(
      table,
      columns: ['imageData'],
      where: 'id = ?',
      whereArgs: [postId],
    );

    if (result.isNotEmpty) {
      return result.first['imageData'];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPostsByUserId(int userId) async {
    if (db == null || !db!.isOpen) await open();
    return await db!.query(
      table,
      where: 'authorId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> incrementLikes(int postId) async {
    if (db == null || !db!.isOpen) await open();
    await db!.rawUpdate('UPDATE posts SET likes = likes + 1 WHERE id = ?', [postId]);
  }

  Future<void> close() async {
    await db?.close();
  }
}