import 'package:flutter/material.dart';
import '../supabase/announcement_supabase_helper.dart';

class AnnouncementList extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAnnouncementSelected;

  const AnnouncementList({super.key, this.onAnnouncementSelected});

  @override
  State<AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  List<Map<String, dynamic>> _announcements = [];
  final AnnouncementSupabaseHelper _dbHelper = AnnouncementSupabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final announcements = await _dbHelper.getAllAnnouncements();
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      print('加载公告失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAnnouncements() async {
    setState(() {
      _isLoading = true;
    });
    await _loadAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_announcements.isEmpty) {
      return const SizedBox();
    }

    return RefreshIndicator(
      onRefresh: _refreshAnnouncements,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '公告',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ..._announcements.map((announcement) => _buildAnnouncementCard(announcement)).toList(),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final hasImage = announcement['imageData'] != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.blue[50],
      child: InkWell(
        onTap: () {
          if (widget.onAnnouncementSelected != null) {
            widget.onAnnouncementSelected!(announcement);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.announcement, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text(
                    '公告',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(announcement['createdAt']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                announcement['title']?.toString() ?? '无标题',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                announcement['content']?.toString() ?? '无内容',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              if (hasImage) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.photo, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      '包含图片',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '未知时间';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}-${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}