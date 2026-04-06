import 'package:flutter/material.dart';
import '../database_helper.dart';

class UserInfoPage extends StatefulWidget {
  final SqliteHelper dbHelper;
  final int targetUserId; // 要查询的用户ID

  const UserInfoPage({
    Key? key,
    required this.dbHelper,
    required this.targetUserId,
  }) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String? userName; // 存储查询到的用户名
  String? userEmail; // 存储查询到的邮箱
  String? userPassword;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 页面初始化时获取数据
  }

  // 从数据库查询用户信息
  Future<void> _fetchUserData() async {
    // 1. 获取数据库中所有用户数据
    final allUsers = await widget.dbHelper.queryAll();

    // 2. 遍历查找目标用户
    for (var user in allUsers) {
      if (user['userId'] == widget.targetUserId) {
        // 3. 找到匹配用户后，更新状态
        setState(() {
          userName = user['name']?.toString(); // 获取用户名
          userEmail = user['email']?.toString(); // 获取邮箱
          userPassword = user['userPassword']?.toString();
        });
        return; // 找到后立即返回
      }
    }

    // 4. 如果没找到用户
    setState(() {
      userName = '用户不存在';
      userEmail = '无邮箱信息';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户信息查询'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('用户ID: ${widget.targetUserId}',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('用户名: ${userName ?? "加载中..."}'),
            Text('邮箱: ${userEmail ?? "加载中..."}'),
            Text('用户密码:${userPassword ?? "加载中..."}'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _fetchUserData, // 点击重新查询
              child: Text('刷新数据'),
            ),
          ],
        ),
      ),
    );
  }
}