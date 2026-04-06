import 'package:flutter/material.dart';
import 'login_page.dart';
import '../supabase/user_supabase_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final UserSupabaseHelper dbHelper = UserSupabaseHelper();
  bool isLoading = false;

  void registerButtonClicked() async {

    if (isLoading) return;

    final userIdStr = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (userIdStr.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('所有字段不能为空');
      return;
    }
    if (password != confirmPassword) {
      showMessage('两次密码不一致');
      return;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      showMessage('账号必须是数字');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (await dbHelper.isUserIdExists(userId)) {
        showMessage('该账号已被注册');
        return;
      }

      await dbHelper.registerUser(
        userId: userId,
        email: email,
        password: password,
      );

      showMessage('注册成功');
      Navigator.pop(context); // 返回登录页
    } catch (e) {
      showMessage('注册失败: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户注册'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: usernameController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '输入账号（数字）',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '邮箱（用于登录）',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '输入密码',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '再次输入密码',
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.5),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: TextButton(
                onPressed: registerButtonClicked,
                child: const Text('注册'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}