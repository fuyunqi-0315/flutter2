import 'package:flutter/material.dart';
import 'admin_feedback_page.dart';
import 'admin_approval_page.dart';
import 'admin_manage_page.dart';
import 'admin_announcement_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    AdminFeedbackPage(),
    AdminApprovalPage(),
    AdminManagePage(),
    AdminAnnouncementPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedIndex)),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '管理员',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('用户反馈管理'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.verified),
              title: Text('帖子审核'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('帖子管理'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('发布公告'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return '用户反馈管理';
      case 1:
        return '帖子审核';
      case 2:
        return '帖子管理';
      case 3:
        return '发布公告';
      default:
        return '';
    }
  }
}