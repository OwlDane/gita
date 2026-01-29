import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wawasan'),
      ),
      body: const Center(
        child: Text('Segera hadir di Phase 4! 📊'),
      ),
    );
  }
}
