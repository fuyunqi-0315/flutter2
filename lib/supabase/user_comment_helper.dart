import 'package:supabase_flutter/supabase_flutter.dart';

class CommentSupabaseHelper {
  final String table = 'comments';
  SupabaseClient get _supabase => Supabase.instance.client;

  // 插入评论
  Future<Map<String, dynamic>> insertComment(Map<String, dynamic> commentData) async {
    try {
      final data = {
        'post_id': commentData['postId'],
        'user_id': commentData['userId'],
        'content': commentData['content'],
        'created_at': commentData['createdAt'] ?? DateTime.now().toIso8601String(),
      };

      final response = await _supabase.from(table).insert(data).select().single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('插入评论错误: $e');
      rethrow;
    }
  }

  // 获取帖子的所有评论
  Future<List<Map<String, dynamic>>> getCommentsByPostId(int postId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取帖子评论错误: $e');
      rethrow;
    }
  }

  // 删除评论
  Future<void> deleteComment(int commentId) async {
    try {
      await _supabase.from(table).delete().eq('id', commentId);
    } catch (e) {
      print('删除评论错误: $e');
      rethrow;
    }
  }

  // 获取用户的评论
  Future<List<Map<String, dynamic>>> getCommentsByUserId(int userId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取用户评论错误: $e');
      rethrow;
    }
  }

  // 删除帖子的所有评论
  Future<void> deleteCommentsByPostId(int postId) async {
    try {
      await _supabase.from(table).delete().eq('post_id', postId);
    } catch (e) {
      print('删除帖子评论错误: $e');
      rethrow;
    }
  }

  // 字段名转换
  Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'postId': data['post_id'],
      'userId': data['user_id'],
      'content': data['content'],
      'createdAt': data['created_at'],
    };
  }
}