import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementSupabaseHelper {
  final String table = 'announcements';
  SupabaseClient get _supabase => Supabase.instance.client;

  // 插入公告
  Future<Map<String, dynamic>> insertAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final data = {
        'title': announcementData['title'],
        'content': announcementData['content'],
        'created_at': announcementData['createdAt'] ?? DateTime.now().toIso8601String(),
      };

      // 只有在有图片数据时才添加
      if (announcementData['imageData'] != null) {
        data['image_data'] = announcementData['imageData'];
      }

      final response = await _supabase.from(table).insert(data).select().single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('插入公告错误: $e');
      rethrow;
    }
  }

  // 查询所有公告
  Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    try {
      final response = await _supabase.from(table).select().order('created_at', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取公告错误: $e');
      rethrow;
    }
  }

  // 删除公告
  Future<void> deleteAnnouncement(int announcementId) async {
    try {
      await _supabase.from(table).delete().eq('id', announcementId);
    } catch (e) {
      print('删除公告错误: $e');
      rethrow;
    }
  }

  // 字段名转换
  Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'title': data['title'],
      'content': data['content'],
      'imageData': data['image_data'],
      'createdAt': data['created_at'],
    };
  }
}