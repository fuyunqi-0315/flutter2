import 'package:supabase_flutter/supabase_flutter.dart';

class ForumPostSupabaseHelper {
  final String table = 'posts';
  SupabaseClient get _supabase => Supabase.instance.client;

  // 插入帖子
  Future<Map<String, dynamic>> insertPost(Map<String, dynamic> postData) async {
    try {
      final data = {
        'title': postData['title'],
        'content': postData['content'],
        'author_id': postData['authorId'],
        'created_at': postData['createdAt'] ?? DateTime.now().toIso8601String(),
        'zone_type': postData['zoneType'] ?? 'other',
        'is_approved': postData['isApproved'] ?? false,
      };

      if (postData['imageData'] != null) {
        data['image_data'] = postData['imageData'];
      }

      final response = await _supabase.from(table).insert(data).select().single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('插入帖子错误: $e');
      rethrow;
    }
  }

  // 获取所有帖子
  Future<List<Map<String, dynamic>>> getAllPosts() async {
    try {
      final response = await _supabase.from(table).select().order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取所有帖子错误: $e');
      rethrow;
    }
  }

  // 获取已批准的帖子
  Future<List<Map<String, dynamic>>> getApprovedPosts() async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取已批准帖子错误: $e');
      rethrow;
    }
  }

  // 获取待审核的帖子
  Future<List<Map<String, dynamic>>> getPendingPosts() async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('is_approved', false)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取待审核帖子错误: $e');
      rethrow;
    }
  }

  // 根据分区获取帖子
  Future<List<Map<String, dynamic>>> getPostsByZone(String zoneType) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('zone_type', zoneType)
          .eq('is_approved', true)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('根据分区获取帖子错误: $e');
      rethrow;
    }
  }

  // 根据作者获取帖子
  Future<List<Map<String, dynamic>>> getPostsByAuthor(int authorId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('author_id', authorId)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('根据作者获取帖子错误: $e');
      rethrow;
    }
  }

  // 根据作者获取已批准的帖子
  Future<List<Map<String, dynamic>>> getApprovedPostsByAuthor(int authorId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('author_id', authorId)
          .eq('is_approved', true)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('根据作者获取已批准帖子错误: $e');
      rethrow;
    }
  }

  // 根据ID获取单个帖子
  Future<Map<String, dynamic>?> getPostById(int postId) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('id', postId)
          .single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('获取帖子详情错误: $e');
      return null;
    }
  }

  // 更新帖子审核状态
  Future<void> updatePostApproval(int postId, bool isApproved) async {
    try {
      await _supabase.from(table).update({'is_approved': isApproved}).eq('id', postId);
    } catch (e) {
      print('更新帖子审核状态错误: $e');
      rethrow;
    }
  }

  // 更新帖子（支持 likes）
  Future<void> updatePost(int postId, Map<String, dynamic> updatedData) async {
    try {
      final data = <String, dynamic>{};

      if (updatedData.containsKey('title')) data['title'] = updatedData['title'];
      if (updatedData.containsKey('content')) data['content'] = updatedData['content'];
      if (updatedData.containsKey('zoneType')) data['zone_type'] = updatedData['zoneType'];
      if (updatedData.containsKey('likes')) data['likes'] = updatedData['likes']; // ✅ 新增这一行

      if (data.isEmpty) return; // 没有要更新的字段

      await _supabase.from(table).update(data).eq('id', postId);
    } catch (e) {
      print('更新帖子错误: $e');
      rethrow;
    }
  }

  // 删除帖子
  Future<void> deletePost(int postId) async {
    try {
      await _supabase.from(table).delete().eq('id', postId);
    } catch (e) {
      print('删除帖子错误: $e');
      rethrow;
    }
  }

  // 根据标题搜索帖子
  Future<List<Map<String, dynamic>>> getPostsByTitle(String title) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .ilike('title', '%$title%')
          .eq('is_approved', true)
          .order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('根据标题搜索帖子错误: $e');
      rethrow;
    }
  }

  // 增加点赞数
  Future<void> incrementLikes(int postId) async {
    try {
      final currentPost = await _supabase.from(table).select('likes').eq('id', postId).single();
      final currentLikes = currentPost['likes'] ?? 0;
      await _supabase.from(table).update({'likes': currentLikes + 1}).eq('id', postId);
    } catch (e) {
      print('增加点赞数错误: $e');
      rethrow;
    }
  }

  // 字段名转换
  Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'title': data['title'],
      'content': data['content'],
      'authorId': data['author_id'],
      'createdAt': data['created_at'],
      'imageData': data['image_data'],
      'likes': data['likes'],
      'zoneType': data['zone_type'],
      'isApproved': data['is_approved'],
    };
  }
}