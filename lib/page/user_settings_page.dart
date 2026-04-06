import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // 导入以使用 base64Encode
import '../supabase/user_supabase_helper.dart'; // 导入更新后的 UserSupabaseHelper
import '../user_manager.dart';

class UserSettingsPage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const UserSettingsPage({
    Key? key,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  File? _selectedAvatar;
  File? _selectedBackground;
  bool _isLoading = false;
  final UserSupabaseHelper _userHelper = UserSupabaseHelper();

  Future<void> _pickAvatar() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedAvatar = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBackground() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedBackground = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveSettings() async {
    final int? userId = UserManager.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<int>? avatarBytes;
      List<int>? backgroundBytes;

      // 读取头像文件
      if (_selectedAvatar != null) {
        avatarBytes = await _selectedAvatar!.readAsBytes();
        print('读取头像文件: ${avatarBytes.length} bytes');
      }

      // 读取背景图文件
      if (_selectedBackground != null) {
        backgroundBytes = await _selectedBackground!.readAsBytes();
        print('读取背景图文件: ${backgroundBytes.length} bytes');
      }

      // 保存到数据库
      await _userHelper.updateUserImages(
        userId: userId,
        avatarData: avatarBytes,
        backgroundData: backgroundBytes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('个性化设置保存成功!')),
      );

      // 回调通知更新
      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }

      Navigator.pop(context);

    } catch (e) {
      print('保存设置失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个性化设置'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '头像设置',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: _selectedAvatar == null
                                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                                : ClipOval(
                              child: Image.file(_selectedAvatar!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('点击选择头像图片'),
                              Text(
                                _selectedAvatar == null
                                    ? '未选择头像'
                                    : '已选择头像',
                                style: TextStyle(
                                  color: _selectedAvatar == null ? Colors.grey : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 背景图设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '背景图设置',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickBackground,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedBackground == null
                            ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('点击选择背景图', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedBackground!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedBackground == null
                          ? '未选择背景图'
                          : '已选择背景图',
                      style: TextStyle(
                        color: _selectedBackground == null ? Colors.grey : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text('保存设置', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}