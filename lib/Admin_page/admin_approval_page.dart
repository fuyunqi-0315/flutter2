import 'package:flutter/material.dart';
import '../../supabase/forum_post_supabase_helper.dart';
import 'admin_post_list.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),

        ),
        Expanded(
          child: AdminPostList(
            mt: "all",
          ),
        ),
      ],
    );
  }
}