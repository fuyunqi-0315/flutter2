// lib/supabase/post_like_supabase_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PostLikeSupabaseHelper {
  final String _table = 'post_likes';
  SupabaseClient get _supabase => Supabase.instance.client;

  /// 检查用户是否已点赞某帖子
  Future<bool> hasUserLikedPost(int postId, int userId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('检查点赞状态失败: $e');
      return false;
    }
  }

  /// 添加点赞记录
  Future<void> addLike(int postId, int userId) async {
    try {
      await _supabase
          .from(_table)
          .insert({
        'post_id': postId,
        'user_id': userId,
      });
    } catch (e) {
      print('添加点赞失败: $e');
      rethrow;
    }
  }

  /// 取消点赞（删除记录）
  Future<void> removeLike(int postId, int userId) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } catch (e) {
      print('取消点赞失败: $e');
      rethrow;
    }
  }

  /// 获取某个帖子的总点赞数（兼容旧版写法）
  Future<int> getLikeCount(int postId) async {
    try {
      // ❌ 不使用 count 参数（旧版不支持）
      // ✅ 改为查询所有记录，用 length 计算
      final response = await _supabase
          .from(_table)
          .select('post_id') // 只选一列，节省流量
          .eq('post_id', postId);
      return response.length;
    } catch (e) {
      print('获取点赞数失败: $e');
      return 0;
    }
  }

  /// 获取某用户点赞的所有帖子 ID 列表
  Future<List<int>> getLikedPostIdsByUser(int userId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select('post_id')
          .eq('user_id', userId);
      return response.map((row) => row['post_id'] as int).toList();
    } catch (e) {
      print('获取用户点赞列表失败: $e');
      return [];
    }
  }
}