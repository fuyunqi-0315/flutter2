import 'package:flutter/material.dart';
import '../supabase/user_feedback_helper.dart'; // 导入 Supabase helper
import '../user_manager.dart';

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  late final TextEditingController _controller;
  final UserFeedbackSupabaseHelper _dbHelper = UserFeedbackSupabaseHelper(); // 改为 Supabase

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    final userId = UserManager.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户未登录')),
      );
      return;
    }

    try {
      await _dbHelper.insertFeedback({
        'userId': userId,
        'feedbackContent': _controller.text,
        'feedbackTime': DateTime.now().toIso8601String(), // 改为 ISO 格式
        'isResolved': false, // 改为布尔值
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('反馈提交成功')),
      );
      _controller.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('反馈问题'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '请输入反馈内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}