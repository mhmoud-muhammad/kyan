// lib/presentation/screens/manager/manager_home_screen.dart
import 'package:flutter/material.dart';

class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المدير')),
      body: const Center(
        child: Text('واجهة المدير', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
