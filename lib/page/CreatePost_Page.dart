import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../supabase/forum_post_supabase_helper.dart';
import '../user_manager.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  Uint8List? _imageBytes;
  final ForumPostSupabaseHelper _dbHelper = ForumPostSupabaseHelper();
  bool _isSubmitting = false;

  String? _selectedZone;
  final List<Map<String, dynamic>> _zones = [
    {'value': 'sports', 'label': '运动'},
    {'value': 'games', 'label': '游戏'},
    {'value': 'music', 'label': '音乐'},
    {'value': 'movies', 'label': '电影'},
    {'value': 'anime', 'label': '动漫'},
    {'value': 'study', 'label': '学习'},
    {'value': 'other', 'label': '其他'},
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 50, // 降低图片质量
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final imageBytes = await file.readAsBytes();

      setState(() {
        _selectedImage = file;
        _imageBytes = imageBytes;
      });
    }
  }

  Future<void> _submitPost() async {
    final int? userId = UserManager.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写标题和内容')),
      );
      return;
    }

    if (_selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择帖子所属专区')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageBase64;
      if (_imageBytes != null) {
        imageBase64 = 'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
      }

      final postData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'authorId': userId,
        'createdAt': DateTime.now().toIso8601String(),
        'imageData': imageBase64,
        'zoneType': _selectedZone,
        'isApproved': false,
      };

      await _dbHelper.insertPost(postData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('帖子发布成功，等待审核中...')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布新帖子',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '请输入帖子标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _selectedZone,
                hint: const Text('选择帖子专区'),
                isExpanded: true,
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedZone = newValue;
                  });
                },
                items: _zones.map<DropdownMenuItem<String>>((zone) {
                  return DropdownMenuItem<String>(
                    value: zone['value'],
                    child: Text(zone['label']),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '请输入帖子内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _selectedImage == null
                    ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40),
                      Text('点击添加图片'),
                    ],
                  ),
                )
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('发布帖子'),
            ),
          ],
        ),
      ),
    );
  }
}