
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase
  await Supabase.initialize(
    url: 'https://tucfgvjhbtrfogltqjod.supabase.co',
    anonKey: 'sb_publishable_5sZng4ajZbZXlID5oH4aTw_fXq1JbX1',
  );

  runApp(const MyApp());
}