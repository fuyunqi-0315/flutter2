import 'package:flutter/material.dart';
import '../post/list.dart';

class ZonePage extends StatelessWidget {
  const ZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专区',
          style: TextStyle(
              color: Colors.white
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildZoneCard(
            context: context,
            title: '运动',
            icon: Icons.sports_baseball,
            color: Colors.blue,
            zoneType: 'sports',
          ),
          _buildZoneCard(
            context: context,
            title: '游戏',
            icon: Icons.sports_esports,
            color: Colors.green,
            zoneType: 'games',
          ),
          _buildZoneCard(
            context: context,
            title: '音乐',
            icon: Icons.music_note,
            color: Colors.orange,
            zoneType: 'music',
          ),
          _buildZoneCard(
            context: context,
            title: '电影',
            icon: Icons.movie,
            color: Colors.purple,
            zoneType: 'movies',
          ),
          _buildZoneCard(
            context: context,
            title: '动漫',
            icon: Icons.animation,
            color: Colors.pink,
            zoneType: 'anime',
          ),
          _buildZoneCard(
            context: context,
            title: '学习',
            icon: Icons.school,
            color: Colors.teal,
            zoneType: 'study',
          ),
          _buildZoneCard(
            context: context,
            title: '其他',
            icon: Icons.category,
            color: Colors.grey,
            zoneType: 'other',
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String zoneType,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('$title专区',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: color,
                ),
                body: Postlist(mt: zoneType), // 直接使用 Postlist
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}