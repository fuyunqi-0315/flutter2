import 'package:flutter/material.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        // 如果是初始路由，手动添加参数
        if (settings.name == AppRoutes.home && settings.arguments == null) {
          return AppRoutes.generateRoute(RouteSettings(
            name: AppRoutes.home,
            arguments: {
              AppRoutes.paramTargetUserId: 1,
            },
          ));
        }
        return AppRoutes.generateRoute(settings);
      },
    );
  }
}