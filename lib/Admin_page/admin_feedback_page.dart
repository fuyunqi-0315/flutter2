import 'package:flutter/material.dart';
import '../supabase/user_feedback_helper.dart'; // 导入 Supabase helper

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  final UserFeedbackSupabaseHelper _dbHelper = UserFeedbackSupabaseHelper(); // 改为 Supabase
  List<Map<String, dynamic>> _feedbacks = [];
  bool _showResolved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    try {
      final feedbacks = await _dbHelper.getAllFeedbacks();
      setState(() {
        _feedbacks = feedbacks;
        _isLoading = false;
      });
    } catch (e) {
      print('加载反馈失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleResolveStatus(int feedbackId, bool currentStatus) async {
    try {
      await _dbHelper.updateFeedbackStatus(feedbackId, !currentStatus);
      await _loadFeedbacks();
    } catch (e) {
      print('更新反馈状态失败: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredFeedbacks() {
    if (_showResolved) {
      return _feedbacks; // 显示所有反馈
    } else {
      // 过滤出未解决的反馈
      return _feedbacks.where((feedback) => !feedback['isResolved']).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFeedbacks = _getFilteredFeedbacks();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_showResolved ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showResolved = !_showResolved;
              });
            },
            tooltip: _showResolved ? '隐藏已解决' : '显示已解决',
          ),
        ],
      ),
      body:
          _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredFeedbacks.isEmpty
          ? const Center(child: Text('暂无用户反馈'))
          : ListView.builder(
        itemCount: filteredFeedbacks.length,
        itemBuilder: (context, index) {
          final feedback = filteredFeedbacks[index];
          final isResolved = feedback['isResolved'] == true;

          return Card(
            margin: const EdgeInsets.all(10),
            color: isResolved ? Colors.grey[100] : null,
            child: ListTile(
              title: Text('用户ID: ${feedback['userId']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(feedback['feedbackContent']?.toString() ?? ''),
                  const SizedBox(height: 8),
                  Text(
                    '时间: ${_formatDate(feedback['feedbackTime'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '状态: ${isResolved ? '已解决' : '未解决'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isResolved ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  isResolved ? Icons.check_circle : Icons.check_circle_outline,
                  color: isResolved ? Colors.green : Colors.grey,
                ),
                onPressed: () => _toggleResolveStatus(
                    feedback['id'],
                    isResolved
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '未知时间';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}