import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/app_environments.dart';
import 'features/dashboard/presentation/screen/dashboard.dart';

void main() {
  AppConfig.setEnvironment(Flavors.production);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}
