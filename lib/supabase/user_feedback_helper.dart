import 'package:supabase_flutter/supabase_flutter.dart';

class UserFeedbackSupabaseHelper {
  final String table = 'user_feedback';
  SupabaseClient get _supabase => Supabase.instance.client;

  // 插入用户反馈
  Future<Map<String, dynamic>> insertFeedback(Map<String, dynamic> feedbackData) async {
    try {
      final data = {
        'user_id': feedbackData['userId'],
        'feedback_content': feedbackData['feedbackContent'],
        'feedback_time': feedbackData['feedbackTime'] ?? DateTime.now().toIso8601String(),
        'is_resolved': feedbackData['isResolved'] ?? false,
      };

      final response = await _supabase.from(table).insert(data).select().single();
      return _convertToCamelCase(response);
    } catch (e) {
      print('插入用户反馈错误: $e');
      rethrow;
    }
  }

  // 查询所有反馈
  Future<List<Map<String, dynamic>>> getAllFeedbacks() async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .order('feedback_time', ascending: false);
      return response.map(_convertToCamelCase).toList();
    } catch (e) {
      print('获取用户反馈错误: $e');
      rethrow;
    }
  }

  // 更新反馈解决状态
  Future<void> updateFeedbackStatus(int feedbackId, bool isResolved) async {
    try {
      await _supabase
          .from(table)
          .update({'is_resolved': isResolved})
          .eq('id', feedbackId);
    } catch (e) {
      print('更新反馈状态错误: $e');
      rethrow;
    }
  }

  // 字段名转换
  Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'userId': data['user_id'],
      'feedbackContent': data['feedback_content'],
      'feedbackTime': data['feedback_time'],
      'isResolved': data['is_resolved'],
    };
  }
}