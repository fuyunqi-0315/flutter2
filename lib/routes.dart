import 'package:flutter/material.dart';
import 'page/home_page.dart';
import 'page/Login_page.dart';
import 'page/FeedbackForm_page.dart';
import 'page/ReviseUser_page.dart';
// import 'page/PostCountPage.dart';
import 'page/ZonePage.dart';
import 'page/SearchPage.dart';
import 'page/CreatePost_Page.dart';
import 'page/DelUserpost_page.dart';
import 'page/user_Settings_page.dart';
import '../post/list.dart';
import 'page/user_profile_page.dart';
import 'page/Comment_page.dart';
import 'page/following_list_page.dart';

class AppRoutes {
  // 路由名称常量
  static const String home = '/';
  static const String login = '/login';
  static const String system = '/system';
  static const String liveHelp = '/liveHelp';
  static const String feedback = '/feedback';
  static const String reviseUser = '/reviseUser';
  // static const String postCount = '/postCount';
  static const String zone = '/zone';
  static const String search = '/search';
  static const String createPost = '/createPost';
  static const String deleteUserPost = '/deleteUserPost';
  static const String postList = '/postList';
  static const String userSettings = '/userSettings';
  static const String userProfile = '/userProfile';
  static const String comment = '/comment';
  static const String followingList = '/following-list';

  // 路由参数键
  static const String paramTargetUserId = 'targetUserId';
  static const String paramUserId = 'userId';
  static const String paramMt = 'mt';
  static const String paramPostId = 'postId';

  // 路由生成器
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomePage(
            targetUserId: args?[paramTargetUserId] ?? 1,
          ),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackFormPage());

      case reviseUser:
        return MaterialPageRoute(
          builder: (_) => ReviseUserPage(
            userId: args?[paramUserId] ?? 1,
            onProfileUpdated: args?['onProfileUpdated'],
          ),
        );

    // case postCount:
    //   return MaterialPageRoute(builder: (_) => const PostCountPage());

      case zone:
        return MaterialPageRoute(builder: (_) => const ZonePage());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());

      case createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostPage());

      case deleteUserPost:
        return MaterialPageRoute(builder: (_) => const DeluserpostPage());

      case postList:
        return MaterialPageRoute(
          builder: (_) => Postlist(
            mt: args?[paramMt] ?? "data",
            targetUserId: args?['targetUserId'], // 传递用户ID参数
          ),
        );

      case userSettings:
        return MaterialPageRoute(
          builder: (_) => UserSettingsPage(
            onProfileUpdated: args?['onProfileUpdated'],
          ),
        );

      case userProfile:
        return MaterialPageRoute(
          builder: (_) => UserProfilePage(
            onProfileUpdated: args?['onProfileUpdated'],
          ),
        );

      case followingList:
        return MaterialPageRoute(
          builder: (_) => FollowingListPage(
            userId: args?[paramUserId] ?? 1,
          ),
        );

      case comment:
        return MaterialPageRoute(
          builder: (_) => CommentPage(
            postId: args?[paramPostId],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('页面未找到')),
            body: Center(
              child: Text('未找到页面: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // 便捷导航方法
  static void navigateTo(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void navigateReplacement(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }
}