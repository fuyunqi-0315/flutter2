import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../supabase/user_supabase_helper.dart';
import '../user_manager.dart';
import '../routes.dart';
import '../post/list.dart';

class UserProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const UserProfilePage({
    Key? key,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  final UserSupabaseHelper _dbHelper = UserSupabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final int? userId = UserManager.getUserId();
    print('当前用户ID: $userId');

    if (userId == null) {
      setState(() {
        _errorMessage = '用户未登录或登录信息已失效';
        _isLoading = false;
      });
      return;
    }

    try {
      final userData = await _dbHelper.getUserById(userId);
      print('查询到的用户数据: $userData');

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载用户数据失败: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildUserAvatar() {
    final avatarData = _userData?['avatarData'];

    if (avatarData == null) {
      return const CircleAvatar(
        radius: 40,
        child: Icon(Icons.person, size: 30),
      );
    }

    if (avatarData is String && avatarData.startsWith('http')) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(avatarData),
      );
    }

    if (avatarData is String) {
      try {
        Uint8List bytes;
        if (avatarData.startsWith('data:image')) {
          bytes = base64.decode(avatarData.split(',').last);
        } else {
          bytes = base64.decode(avatarData);
        }
        return CircleAvatar(
          radius: 40,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        print('个人资料页头像解码失败: $e');
      }
    }

    return const CircleAvatar(
      radius: 40,
      child: Icon(Icons.person, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: Colors.teal,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return _buildProfileContent();
  }

  Widget _buildProfileContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUserAvatar(),
                const SizedBox(height: 16),
                Text(
                  _userData?['name'] ?? '未设置名称',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_userData?['email'] ?? '未绑定邮箱'),
                const SizedBox(height: 4),
                Text('用户ID: ${_userData?['userId'] ?? ''}'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.purple),
                title: const Text('个性化设置'),
                subtitle: const Text('修改头像和背景图'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.userSettings,
                    arguments: {
                      'onProfileUpdated': () {
                        _loadUserData();
                        widget.onProfileUpdated?.call();
                      },
                    },
                  );
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('修改个人信息'),
                subtitle: const Text('修改邮箱和姓名'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final userId = UserManager.getUserId();
                  if (userId != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.reviseUser,
                      arguments: {
                        'userId': userId,
                        'onProfileUpdated': () {
                          _loadUserData();
                          widget.onProfileUpdated?.call();
                        },
                      },
                    );
                  }
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.article, color: Colors.green),
                title: const Text('我的帖子'),
                subtitle: const Text('查看我发布的帖子'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final userId = UserManager.getUserId();
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('我的帖子',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                          body: Postlist(mt: "user", targetUserId: userId),
                        ),
                      ),
                    );
                  }
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.people, color: Colors.orange),
                title: const Text('我的关注'),
                subtitle: const Text('查看我关注的用户'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final userId = UserManager.getUserId();
                  if (userId != null) {
                    AppRoutes.navigateTo(
                      context,
                      AppRoutes.followingList,
                      arguments: {
                        AppRoutes.paramUserId: userId,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}