import '../post/list.dart';
import 'package:flutter/material.dart';
import '../supabase/user_supabase_helper.dart';
import '../local_user_images_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowingListPage extends StatefulWidget {
  final int userId;

  const FollowingListPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<FollowingListPage> createState() => _FollowingListPageState();
}

class _FollowingListPageState extends State<FollowingListPage> {
  List<Map<String, dynamic>> _followingUsers = [];
  bool _isLoading = true;
  final UserSupabaseHelper _userHelper = UserSupabaseHelper();
  final LocalUserImagesHelper _localImagesHelper = LocalUserImagesHelper();

  @override
  void initState() {
    super.initState();
    _loadFollowingUsers();
  }

  Future<void> _loadFollowingUsers() async {
    try {

      final List? followsData = await Supabase.instance.client
          .from('follows')
          .select('followee_id')
          .eq('follower_id', widget.userId);

      if (followsData == null || followsData.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 提取 followee_id 列表
      final List<int> followeeIds = followsData
          .map((row) => (row as Map<String, dynamic>)['followee_id'] as int)
          .toList();

      // 调用 helper 方法（不是自己实现！）
      final usersResponse = await _userHelper.getUsersByIds(followeeIds);
      if (usersResponse == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 补充本地头像
      final List<Map<String, dynamic>> usersWithAvatars = [];
      for (var user in usersResponse) {
        final localImages = await _localImagesHelper.getUserImages(user['userId']);
        if (localImages != null && localImages['avatarData'] != null) {
          user = Map<String, dynamic>.from(user)..['avatarData'] = localImages['avatarData'];
        }
        usersWithAvatars.add(user);
      }

      setState(() {
        _followingUsers = usersWithAvatars;
        _isLoading = false;
      });
    } catch (e) {
      print('加载关注列表失败: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${e.toString().substring(0, 50)}...')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return ListTile(
      leading: _buildAvatar(user),
      title: Text(user['name'] ?? '用户${user['userId']}'),
      subtitle: Text('ID: ${user['userId']}'),
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('${user['name'] ?? '用户${user['userId']}'} 的帖子',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
              body: Postlist(
                mt: "user",
                targetUserId: user['userId'],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    if (user['avatarData'] != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(user['avatarData']),
      );
    } else {
      return const CircleAvatar(
        radius: 20,
        child: Icon(Icons.person, size: 16, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的关注'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followingUsers.isEmpty
          ? const Center(child: Text('暂未关注任何用户'))
          : ListView.builder(
        itemCount: _followingUsers.length,
        itemBuilder: (context, index) {
          return _buildUserItem(_followingUsers[index]);
        },
      ),
    );
  }
}