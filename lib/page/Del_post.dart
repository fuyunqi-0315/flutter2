import 'package:flutter/material.dart';
import '../supabase/forum_post_supabase_helper.dart';

class DeletePostPage extends StatelessWidget {
  final String postTitle;

  const DeletePostPage({
    super.key,
    required this.postTitle,
  });

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除帖子'),
        content: Text('确定要删除标题为"$postTitle"的帖子吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deletePost(context);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _deletePost(BuildContext context) async {
    try {
      // 搜索匹配的帖子
      final matchingPosts = await ForumPostSupabaseHelper().getPostsByTitle(postTitle);

      if (matchingPosts.isEmpty) {
        // 直接显示提示并返回
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('未找到标题为"$postTitle"的帖子')),
        );
        Navigator.pop(context);
        return;
      }

      // 逐个删除匹配的帖子
      int deletedCount = 0;
      for (final post in matchingPosts) {
        try {
          await ForumPostSupabaseHelper().deletePost(post['id']);
          deletedCount++;
        } catch (e) {
          print('删除帖子 ${post['id']} 失败: $e');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功删除 $deletedCount 个帖子!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 页面加载时立即显示对话框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDeleteDialog(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('删除帖子'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('正在加载...'),
          ],
        ),
      ),
    );
  }
}