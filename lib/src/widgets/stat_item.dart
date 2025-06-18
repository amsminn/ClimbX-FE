import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String label;
  const StatItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey));
  }
}
