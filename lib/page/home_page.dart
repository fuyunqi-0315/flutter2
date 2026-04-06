import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../supabase/user_supabase_helper.dart';
import '../post/list.dart';
import 'zonePage.dart';
import 'user_profile_page.dart';
import '../routes.dart';
import '../post/announcement_list.dart';

class HomePage extends StatefulWidget {
  final int targetUserId;

  const HomePage({
    Key? key,
    required this.targetUserId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final UserSupabaseHelper _dbHelper = UserSupabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _onProfileUpdated() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _dbHelper.getUserById(widget.targetUserId);
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('加载用户数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserAvatar() {
    final avatarBase64 = _userData?['avatarData'];
    if (avatarBase64 is String && avatarBase64.isNotEmpty) {
      try {
        Uint8List bytes;
        if (avatarBase64.startsWith('data:image')) {
          bytes = base64.decode(avatarBase64.split(',').last);
        } else {
          bytes = base64.decode(avatarBase64);
        }
        return CircleAvatar(radius: 50, backgroundImage: MemoryImage(bytes));
      } catch (e) {
        print('头像解码失败: $e');
      }
    }
    return const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 40));
  }

  BoxDecoration _buildBackgroundDecoration() {
    final backgroundBase64 = _userData?['backgroundData'];
    if (backgroundBase64 is String && backgroundBase64.isNotEmpty) {
      try {
        Uint8List bytes;
        if (backgroundBase64.startsWith('data:image')) {
          bytes = base64.decode(backgroundBase64.split(',').last);
        } else {
          bytes = base64.decode(backgroundBase64);
        }
        return BoxDecoration(
          image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
        );
      } catch (e) {
        print('背景图解码失败: $e');
      }
    }
    return const BoxDecoration(color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '论坛',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.search);
              },
            )
          ],
        ),
        drawer: Drawer(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(_userData?['name'] ?? '无名称'),
                    accountEmail: Text(_userData?['email'] ?? '未绑定邮箱'),
                    currentAccountPicture: _buildUserAvatar(),
                    decoration: _buildBackgroundDecoration(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text("修改个人信息", style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.reviseUser,
                          arguments: {
                            'userId': widget.targetUserId,
                            'onProfileUpdated': _onProfileUpdated,
                          },
                        );
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('用户反馈'),
                    trailing: IconButton(
                      icon: const Icon(Icons.feedback, color: Colors.yellow),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.feedback);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('发布作品'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_box_rounded, color: Colors.blue),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.createPost);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('删除作品'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.deleteUserPost);
                      },
                    ),
                  ),
                  const Divider(color: Colors.black),
                  ListTile(
                    title: const Text('注销用户'),
                    trailing: IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                              (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white),
          height: 50,
          child: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home), text: '首页'),
              Tab(icon: Icon(Icons.category), text: '专区'),
              Tab(icon: Icon(Icons.person), text: '我的'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              children: [
                AnnouncementList(),
                Expanded(
                  child: Postlist(mt: "all"),
                ),
              ],
            ),
            ZonePage(),
            UserProfilePage(onProfileUpdated: _onProfileUpdated),
          ],
        ),
      ),
    );
  }
}