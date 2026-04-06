// lib/post/post_detail_page.dart （建议文件名全小写）
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../supabase/forum_post_supabase_helper.dart';
import '../supabase/user_comment_helper.dart';
import '../supabase/post_like_supabase_helper.dart';
import '../supabase/user_supabase_helper.dart';
import '../supabase/follow_supabase_helper.dart'; // ✅ 必须导入
import '../user_manager.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Map<String, dynamic> _post;
  final ForumPostSupabaseHelper _dbHelper = ForumPostSupabaseHelper();
  final CommentSupabaseHelper _commentHelper = CommentSupabaseHelper();
  final PostLikeSupabaseHelper _likeHelper = PostLikeSupabaseHelper();
  final UserSupabaseHelper _userHelper = UserSupabaseHelper();
  final FollowSupabaseHelper _followHelper = FollowSupabaseHelper(); // ✅ 新增
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  bool _hasLiked = false;
  int? _currentUserId;
  Map<String, dynamic>? _author;
  bool _isFollowing = false;

  final Map<int, Map<String, dynamic>?> _commenterCache = {};

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadCurrentUserAndLikes();
    _loadComments();
    _loadAuthorInfo();
  }

  Future<void> _loadCurrentUserAndLikes() async {
    _currentUserId = UserManager.getUserId();

    if (_currentUserId != null) {
      try {
        final liked = await _likeHelper.hasUserLikedPost(_post['id'], _currentUserId!);
        setState(() {
          _hasLiked = liked;
        });
      } catch (e) {
        print('检查点赞状态失败: $e');
      }
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _commentHelper.getCommentsByPostId(_post['id']);
      for (var comment in comments) {
        final userId = comment['userId'] as int?;
        if (userId != null && !_commenterCache.containsKey(userId)) {
          final user = await _userHelper.getUserById(userId);
          _commenterCache[userId] = user;
        }
      }
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      print('加载评论失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _loadAuthorInfo() async {
    try {
      final authorId = _post['authorId'] as int?;
      if (authorId == null) return;

      final author = await _userHelper.getUserById(authorId);
      if (mounted) {
        setState(() {
          _author = author;
        });
        _loadFollowStatus();
      }
    } catch (e) {
      print('加载作者信息失败: $e');
    }
  }

  // ✅ 关键：用 _followHelper，不是 _likeHelper
  Future<void> _loadFollowStatus() async {
    final currentUserId = UserManager.getUserId();
    final authorId = _author?['userId'] as int?;

    if (currentUserId == null || authorId == null || currentUserId == authorId) {
      return;
    }

    try {
      final isFollowing = await _followHelper.isFollowing(currentUserId, authorId); // ✅
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      print('加载关注状态失败: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    try {
      if (_hasLiked) {
        await _likeHelper.removeLike(_post['id'], _currentUserId!);
        final updatedLikes = (_post['likes'] as int) - 1;
        await _dbHelper.updatePost(_post['id'], {'likes': updatedLikes > 0 ? updatedLikes : 0});
        final freshPost = await _dbHelper.getPostById(_post['id']);
        if (freshPost != null) {
          setState(() {
            _post = freshPost;
            _hasLiked = false;
          });
        }
      } else {
        await _likeHelper.addLike(_post['id'], _currentUserId!);
        final updatedLikes = (_post['likes'] as int) + 1;
        await _dbHelper.updatePost(_post['id'], {'likes': updatedLikes});
        final freshPost = await _dbHelper.getPostById(_post['id']);
        if (freshPost != null) {
          setState(() {
            _post = freshPost;
            _hasLiked = true;
          });
        }
      }
    } catch (e) {
      print('切换点赞失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  // ✅ 关键：用 _followHelper
  Future<void> _toggleFollow() async {
    final currentUserId = UserManager.getUserId();
    final authorId = _author?['userId'] as int?;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    if (authorId == null || currentUserId == authorId) {
      return;
    }

    try {
      if (_isFollowing) {
        await _followHelper.unfollowUser(currentUserId, authorId); // ✅
      } else {
        await _followHelper.followUser(currentUserId, authorId); // ✅
      }

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? '已关注' : '已取消关注'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e, stackTrace) {
      print('关注操作失败: $e');
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: ${e.toString().substring(0, 80)}...')),
      );
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    final userId = UserManager.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    try {
      await _commentHelper.insertComment({
        'postId': _post['id'],
        'userId': userId,
        'content': _commentController.text,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _commentController.clear();
      await _loadComments();
    } catch (e) {
      print('评论发布失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评论失败')),
      );
    }
  }

  Widget _buildUserAvatar(Map<String, dynamic>? user, {double radius = 16}) {
    if (user == null) {
      return CircleAvatar(
        radius: radius,
        child: Icon(Icons.person, size: radius * 0.8, color: Colors.grey),
      );
    }

    final avatarData = user['avatarData'];
    if (avatarData == null) {
      return CircleAvatar(
        radius: radius,
        child: Icon(Icons.person, size: radius * 0.8, color: Colors.grey),
      );
    }

    if (avatarData is String && avatarData.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarData),
      );
    }

    if (avatarData is String) {
      try {
        Uint8List bytes;
        if (avatarData.startsWith('data:image')) {
          final base64Part = avatarData.split(',').last;
          bytes = base64.decode(base64Part);
        } else {
          bytes = base64.decode(avatarData);
        }
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        print('头像解码失败: $e');
        return CircleAvatar(
          radius: radius,
          child: Icon(Icons.person, size: radius * 0.8, color: Colors.grey),
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.person, size: radius * 0.8, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _post['imageData'] != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子详情'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_author != null)
                    Row(
                      children: [
                        _buildUserAvatar(_author, radius: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _author!['name'] ?? '用户${_author!['userId']}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_currentUserId != null &&
                            _author!['userId'] != _currentUserId)
                          ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            ),
                            child: Text(
                              _isFollowing ? '已关注' : '关注',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                      ],
                    )
                  else if (_post['authorId'] != null)
                    const Row(
                      children: [
                        SizedBox(width: 44, height: 44, child: CircularProgressIndicator()),
                        SizedBox(width: 12),
                        Text('加载中...', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  const SizedBox(height: 16),

                  Text(
                    _post['title']?.toString() ?? '无标题',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _post['content']?.toString() ?? '无内容',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  if (hasImage)
                    Container(
                      width: double.infinity,
                      child: _buildImageWidget(_post['imageData']),
                    ),
                  const SizedBox(height: 20),

                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getZoneLabel(_post['zoneType']?.toString() ?? 'other'),
                          style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: _hasLiked ? Colors.red : null,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text('${_post['likes'] ?? 0}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment),
                      const SizedBox(width: 4),
                      Text('${_comments.length}'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text('评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return const Center(child: Text('暂无评论'));
    }

    return Column(
      children: _comments.map((comment) => _buildCommentItem(comment)).toList(),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final userId = comment['userId'] as int?;
    final commenter = userId != null ? _commenterCache[userId] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildUserAvatar(commenter, radius: 20),
        title: Text(commenter?['name'] ?? '用户$userId'),
        subtitle: Text(comment['content'] ?? ''),
        trailing: Text(_formatDate(comment['createdAt'])),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '写评论...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _submitComment,
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? imageData) {
    if (imageData != null && imageData.startsWith('data:image')) {
      try {
        final base64Data = imageData.split(',').last;
        final imageBytes = base64.decode(base64Data);
        return Image.memory(imageBytes);
      } catch (e) {
        return _buildErrorImage();
      }
    } else {
      return _buildErrorImage();
    }
  }

  Widget _buildErrorImage() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image)),
    );
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
    };
    return zoneMap[zoneType] ?? '其他';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}