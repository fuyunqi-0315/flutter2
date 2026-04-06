import 'package:flutter/material.dart';
import '../post/list.dart';
import '../supabase/forum_post_supabase_helper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ForumPostSupabaseHelper _dbHelper = ForumPostSupabaseHelper(); // 改为 Supabase helper
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _searching = true;
      _results = [];
    });

    try {
      // 移除 _dbHelper.open() 调用，Supabase 不需要手动打开
      final posts = await _dbHelper.getPostsByTitle(_searchController.text);
      setState(() {
        _results = posts;
        _searching = false;
      });
    } catch (e) {
      print('搜索错误: $e');
      setState(() {
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索帖子'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入帖子标题...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

          // 搜索结果
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(child: Text('没有找到相关帖子'))
                : Postlist(
              mt: 'search',
              externalPosts: _results, // 传入搜索结果
            ),
          )
        ],
      ),
    );
  }
}