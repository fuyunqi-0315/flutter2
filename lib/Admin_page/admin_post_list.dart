import 'package:flutter/material.dart';
import '../post/Postdetailpage.dart';
import '../../supabase/forum_post_supabase_helper.dart';

class AdminPostList extends StatefulWidget {
  final String mt;

  const AdminPostList({
    Key? key,
    required this.mt,
  }) : super(key: key);

  @override
  State<AdminPostList> createState() => _AdminPostListState();
}

class _AdminPostListState extends State<AdminPostList> {
  List<Map<String, dynamic>> _posts = [];
  final ForumPostSupabaseHelper _dbHelper = ForumPostSupabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      List<Map<String, dynamic>> posts;

      if (widget.mt == 'all') {
        posts = await _dbHelper.getAllPosts();
      } else {
        posts = await _dbHelper.getPostsByZone(widget.mt);
      }

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('加载帖子失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approvePost(Map<String, dynamic> post) async {
    try {
      await _dbHelper.updatePostApproval(post['id'], true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('帖子审核通过')),
      );
      _loadPosts();
    } catch (e) {
      print('操作失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  Future<void> _rejectPost(Map<String, dynamic> post) async {
    try {
      await _dbHelper.updatePostApproval(post['id'], false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('帖子已拒绝')),
      );
      _loadPosts();
    } catch (e) {
      print('操作失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  void _navigateToPostDetail(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: _posts.isEmpty
          ? Center(child: Text('暂无帖子'))
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final isApproved = post['isApproved'] == true; // Supabase 使用 boolean
          final hasImage = post['imageData'] != null;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: InkWell(
              onTap: () {
                _navigateToPostDetail(post);
              },
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isApproved ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isApproved ? '已审核' : '待审核',
                            style: TextStyle(
                              fontSize: 12,
                              color: isApproved ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approvePost(post),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectPost(post),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    Text(
                      post['title']?.toString() ?? '无标题',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      _getContentPreview(post['content']?.toString() ?? '无内容'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (hasImage) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.photo, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            '包含图片',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getZoneLabel(post['zoneType']?.toString() ?? 'other'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('${post['likes'] ?? 0}'),
                        SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(post['createdAt']?.toString()),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getContentPreview(String content) {
    if (content.length > 100) {
      return content.substring(0, 100) + '...';
    }
    return content;
  }

  String _getZoneLabel(String zoneType) {
    final zoneMap = {
      'sports': '运动',
      'games': '游戏',
      'music': '音乐',
      'movies': '电影',
      'anime': '动漫',
      'study': '学习',
      'other': '其他',
      'all': '全部',
    };
    return zoneMap[zoneType] ?? '其他';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '未知时间';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}-${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '未知时间';
    }
  }
}