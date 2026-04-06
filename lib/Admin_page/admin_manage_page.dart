import 'package:flutter/material.dart';
import '../supabase/forum_post_supabase_helper.dart';
import '../supabase/announcement_supabase_helper.dart';
import '../../post/list.dart';
import '../../post/announcement_list.dart';

class AdminManagePage extends StatelessWidget {
  const AdminManagePage({super.key});

  Future<void> _deletePost(BuildContext context, Map<String, dynamic> post) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除帖子'),
        content: Text('确定要删除帖子"${post['title']}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final dbHelper = ForumPostSupabaseHelper();
                await dbHelper.deletePost(post['id']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('帖子删除成功')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除失败: $e')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement(BuildContext context, Map<String, dynamic> announcement) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除公告'),
        content: Text('确定要删除公告"${announcement['title']}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final announcementHelper = AnnouncementSupabaseHelper();
                await announcementHelper.deleteAnnouncement(announcement['id']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('公告删除成功')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除失败: $e')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 公告管理 - 添加点击回调
        AnnouncementList(
          onAnnouncementSelected: (announcement) => _deleteAnnouncement(context, announcement),
        ),
        // 帖子管理
        Expanded(
          child: Postlist(
            mt: "all",
            onPostSelected: (post) => _deletePost(context, post),
          ),
        ),
      ],
    );
  }
}