import 'package:flutter/material.dart';
import 'Del_post.dart';
import '../user_manager.dart';
import '../post/list.dart';

class DeluserpostPage extends StatefulWidget {
  const DeluserpostPage({super.key});

  @override
  State<DeluserpostPage> createState() => _DeluserpostPageState();
}

class _DeluserpostPageState extends State<DeluserpostPage> {
  String? _selectedPostTitle;
  int? _selectedPostId;

  void _selectPost(Map<String, dynamic> post) {
    setState(() {
      _selectedPostTitle = post['title'];
      _selectedPostId = post['id'];
    });
  }

  void _confirmDelete() {
    if (_selectedPostTitle != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeletePostPage(postTitle: _selectedPostTitle!),
        ),
      ).then((result) {
        // 删除成功后清空选择
        if (result == true) {
          setState(() {
            _selectedPostTitle = null;
            _selectedPostId = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? userId = UserManager.getUserId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('删除帖子'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // 选择提示
          if (_selectedPostTitle != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '已选择要删除的帖子:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedPostTitle!,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 帖子列表
          Expanded(
            child: userId != null
                ? Postlist(
              mt: "user",
              targetUserId: userId,
              onPostSelected: _selectPost, // 添加选择回调
            )
                : const Center(
              child: Text('用户未登录'),
            ),
          ),

          // 删除按钮
          if (_selectedPostTitle != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('删除选中的帖子'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}