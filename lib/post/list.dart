import 'package:flutter/material.dart';
import '../supabase/forum_post_supabase_helper.dart';
import 'Postdetailpage.dart';

class Postlist extends StatefulWidget {
  final String mt;
  final List<Map<String, dynamic>>? externalPosts;
  final int? targetUserId;
  final Function(Map<String, dynamic>)? onPostSelected;

  const Postlist({
    Key? key,
    required this.mt,
    this.externalPosts,
    this.targetUserId,
    this.onPostSelected,
  }) : super(key: key);

  @override
  State<Postlist> createState() => _PostlistState();
}

class _PostlistState extends State<Postlist> {
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
      if (widget.externalPosts != null) {
        setState(() {
          _posts = widget.externalPosts!;
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> posts;

      if (widget.mt == 'all') {
        posts = await _dbHelper.getApprovedPosts();
      } else if (widget.mt == 'user') {
        if (widget.targetUserId != null) {
          posts = await _dbHelper.getApprovedPostsByAuthor(widget.targetUserId!);
        } else {
          posts = [];
        }
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

  @override
  void didUpdateWidget(Postlist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalPosts != null &&
        widget.externalPosts != oldWidget.externalPosts) {
      setState(() {
        _posts = widget.externalPosts!;
      });
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
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              widget.mt == 'all' ? '暂无帖子' : '暂无${_getZoneLabel(widget.mt)}相关帖子',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final hasImage = post['imageData'] != null;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: InkWell(
              onTap: () {
                if (widget.onPostSelected != null) {
                  widget.onPostSelected!(post);
                } else {
                  _navigateToPostDetail(post);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title']?.toString() ?? '无标题',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      _getContentPreview(post['content']?.toString() ?? '无内容'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
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