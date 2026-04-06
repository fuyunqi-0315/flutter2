import 'package:flutter/material.dart';
import '../supabase/user_supabase_helper.dart';

class ReviseUserPage extends StatefulWidget {
  final int userId;
  final VoidCallback? onProfileUpdated;

  const ReviseUserPage({
    Key? key,
    required this.userId,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  _ReviseUserPageState createState() => _ReviseUserPageState();
}

class _ReviseUserPageState extends State<ReviseUserPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final UserSupabaseHelper _dbHelper = UserSupabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await _dbHelper.getUserById(widget.userId);

      if (userData != null) {
        _emailController.text = userData['email']?.toString() ?? '';
        _nameController.text = userData['name']?.toString() ?? '';
      } else {
        setState(() => _errorMessage = '用户数据不存在');
      }
    } catch (e) {
      setState(() => _errorMessage = '加载数据失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() => _errorMessage = '邮箱和姓名不能为空');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 检查邮箱是否重复
      final allUsers = await _dbHelper.getAllUsers();
      final emailExists = allUsers.any((user) =>
      user['email'] == _emailController.text && user['userId'] != widget.userId);

      if (emailExists) {
        setState(() => _errorMessage = '该邮箱已被其他用户使用');
        return;
      }

      // 修正：传递 Map 参数
      await _dbHelper.updateUser({
        'userId': widget.userId,
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功!')),
      );

      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }

      Navigator.pop(context, true);

    } catch (e) {
      setState(() => _errorMessage = '保存失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改个人信息'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入邮箱地址',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                hintText: '请输入您的姓名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveData,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}