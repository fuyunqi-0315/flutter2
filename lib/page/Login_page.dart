import 'package:flutter/material.dart';
import 'register_page.dart';
import '../supabase/user_supabase_helper.dart';
import 'home_page.dart';
import '../user_manager.dart';
import '../Admin_page/admin_main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  String _errorMessage = '';
  final UserSupabaseHelper _dbHelper = UserSupabaseHelper();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isAdminLogin(String username, String password) {
    return username == 'admin' && password.length == 6;
  }

  void _login() async {
    setState(() {
      _errorMessage = '';
    });

    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '请输入邮箱和密码';
      });
      return;
    }

    // 管理员登录（特殊处理）
    if (_isAdminLogin(email, password)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminMainPage()),
      );
      return;
    }

    try {
      // signInWithPassword 成功直接返回 UserResponse，失败抛出 AuthException
      final userResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 如果没抛异常，说明登录成功
      final supabaseUserId = userResponse.user!.id.toString();
      final userData = await _dbHelper.getUserBySupabaseId(supabaseUserId);

      if (userData == null) {
        setState(() {
          _errorMessage = '用户资料未找到，请联系管理员';
        });
        return;
      }

      final businessUserId = userData['userId'] as int;
      UserManager.setUserId(businessUserId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(targetUserId: businessUserId),
        ),
      );
    } on AuthException catch (e) {
      // 捕获认证错误（如密码错误、用户不存在等）
      setState(() {
        _errorMessage = '邮箱或密码错误';
      });
    } catch (e) {
      // 其他错误（网络、服务器等）
      setState(() {
        _errorMessage = '登录失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户登录'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('登录'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              child: const Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}