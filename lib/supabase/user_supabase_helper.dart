import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class UserSupabaseHelper {
  final String table = 'users';
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> registerUser({
    required int userId,
    required String email,
    required String password,
  }) async {
    try {
      // 1. 注册到 Supabase Auth（新版：失败会抛出 AuthException）
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 如果执行到这里，说明注册成功，user 一定存在
      final supabaseUserId = authResponse.user!.id.toString();

      // 2. 自动插入到业务表 `users`
      final response = await _supabase
          .from('users')
          .insert({
        'user_id': userId,
        'email': email,
        'supabase_user_id': supabaseUserId,
        'name': '新用户',
      })
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('业务数据创建失败');
      }
    } on AuthException catch (e) {
      // 捕获 Supabase 认证错误：邮箱已存在、密码太弱、rate limit 等
      throw Exception('注册失败: ${e.message}');
    } catch (e) {
      // 捕获其他错误：网络、数据库插入失败等
      throw Exception('注册失败: $e');
    }
  }

  // 根据 supabase_user_id 获取用户
  Future<Map<String, dynamic>?> getUserBySupabaseId(String supabaseUserId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('supabase_user_id', supabaseUserId)
          .single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('通过 Supabase ID 获取用户失败: $e');
      return null;
    }
  }

  // 检查 user_id 是否已存在（用于注册时校验）
  Future<bool> isUserIdExists(int userId) async {
    try {
      final response = await _supabase
          .from(table)
          .select('user_id')
          .eq('user_id', userId)
          .limit(1);
      return (response as List).isNotEmpty;
    } catch (e) {
      print('检查 user_id 是否存在失败: $e');
      return false;
    }
  }

  // ===== 以下方法保持不变（用于业务逻辑）=====
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase.from(table).select();
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取所有用户错误: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('user_id', userId)
          .single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('获取用户错误: $e');
      return null;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('删除用户错误: $e');
      rethrow;
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (userData['email'] != null && userData['email'].isNotEmpty) {
        data['email'] = userData['email'];
      }
      if (userData['name'] != null && userData['name'].isNotEmpty) {
        data['name'] = userData['name'];
      }

      await _supabase
          .from(table)
          .update(data)
          .eq('user_id', userData['userId']);
    } catch (e) {
      print('更新用户错误: $e');
      rethrow;
    }
  }

  Future<void> updateUserImages({
    required int userId,
    List<int>? avatarData,
    List<int>? backgroundData,
  }) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarData != null) {
        data['avatar_data'] = base64Encode(avatarData);
      }
      if (backgroundData != null) {
        data['background_data'] = base64Encode(backgroundData);
      }

      await _supabase
          .from(table)
          .update(data)
          .eq('user_id', userId);
    } catch (e) {
      print('更新用户图片错误: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> getUsersByIds(List<int> userIds) async {
    if (userIds.isEmpty) return [];
    try {
      final String orCondition = userIds
          .map((id) => 'user_id.eq.$id')
          .join(',');
      final List? rawData = await _supabase
          .from(table)
          .select()
          .or(orCondition);
      if (rawData == null) return [];
      return rawData
          .map((item) => _convertToCamelCase(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('批量查询用户失败: $e');
      return null;
    }
  }

  Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'userId': data['user_id'],
      'email': data['email'],
      'name': data['name'],
      'avatarData': data['avatar_data'],
      'backgroundData': data['background_data'],
      'createdAt': data['created_at'],
      'updatedAt': data['updated_at'],
    };
  }
}