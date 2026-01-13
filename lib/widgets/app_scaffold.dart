import 'package:flutter/material.dart';
import 'user_dashboard_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const UserDashboardDrawer(),
      body: body,
    );
  }
}
