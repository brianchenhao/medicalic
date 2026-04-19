import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _Placeholder(title: 'Home', subtitle: 'Dashboard coming in Phase 4');
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Placeholder({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
