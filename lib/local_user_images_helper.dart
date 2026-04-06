// lib/local_user_images_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalUserImagesHelper {
  static final LocalUserImagesHelper _instance = LocalUserImagesHelper._internal();
  factory LocalUserImagesHelper() => _instance;
  LocalUserImagesHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'user_images.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_images(
        user_id INTEGER PRIMARY KEY,
        avatar_data BLOB,
        background_data BLOB,
        updated_at INTEGER
      )
    ''');
  }

  // 插入或更新用户头像和背景图
  Future<void> insertOrUpdateUserImages({
    required int userId,
    List<int>? avatarData,
    List<int>? backgroundData,
  }) async {
    final db = await database;

    // 检查是否已存在
    final existing = await db.query(
      'user_images',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (existing.isEmpty) {
      // 插入新记录
      await db.insert('user_images', {
        'user_id': userId,
        'avatar_data': avatarData,
        'background_data': backgroundData,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      print('插入用户图片数据: userId=$userId');
    } else {
      // 更新现有记录
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      if (avatarData != null) {
        updateData['avatar_data'] = avatarData;
      }

      if (backgroundData != null) {
        updateData['background_data'] = backgroundData;
      }

      await db.update(
        'user_images',
        updateData,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('更新用户图片数据: userId=$userId');
    }
  }

  // 获取用户头像和背景图
  Future<Map<String, dynamic>?> getUserImages(int userId) async {
    final db = await database;
    final results = await db.query(
      'user_images',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) {
      print('未找到用户图片数据: userId=$userId');
      return null;
    }

    final data = {
      'avatarData': results.first['avatar_data'],
      'backgroundData': results.first['background_data'],
    };

    print('获取用户图片数据: userId=$userId, 头像=${data['avatarData'] != null}, 背景=${data['backgroundData'] != null}');
    return data;
  }

  // 只更新用户头像
  Future<void> updateUserAvatar(int userId, List<int> avatarData) async {
    final db = await database;
    await db.update(
      'user_images',
      {
        'avatar_data': avatarData,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('更新用户头像: userId=$userId');
  }

  // 只更新用户背景图
  Future<void> updateUserBackground(int userId, List<int> backgroundData) async {
    final db = await database;
    await db.update(
      'user_images',
      {
        'background_data': backgroundData,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('更新用户背景图: userId=$userId');
  }

  // 删除用户图片
  Future<void> deleteUserImages(int userId) async {
    final db = await database;
    await db.delete(
      'user_images',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('删除用户图片数据: userId=$userId');
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}