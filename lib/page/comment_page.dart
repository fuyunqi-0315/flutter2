import 'package:flutter/material.dart';
import '../supabase/user_comment_helper.dart';
import '../user_manager.dart';

class CommentPage extends StatefulWidget {
  final int postId;
  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  final CommentSupabaseHelper _dbHelper = CommentSupabaseHelper();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _dbHelper.getCommentsByPostId(widget.postId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('加载评论失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_controller.text.isEmpty) return;

    final userId = UserManager.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    try {
      await _dbHelper.insertComment({
        'postId': widget.postId,
        'userId': userId,
        'content': _controller.text,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _controller.clear();
      await _loadComments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论发布成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评论发布失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评论 (${_comments.length})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 输入框
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '写评论...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submitComment,
                  child: const Text('发送'),
                ),
              ],
            ),
          ),

          // 评论列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? const Center(child: Text('暂无评论'))
                : ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text(
                        '${comment['userId']}'.substring(0, 1),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text('用户 ${comment['userId']}'),
                    subtitle: Text(comment['content'] ?? ''),
                    trailing: Text(_formatDate(comment['createdAt'])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}