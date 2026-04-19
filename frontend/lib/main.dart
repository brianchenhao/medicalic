import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/message_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    Provider<ApiService>(
      create: (_) => ApiService(),
      child: const MedicalicApp(),
    ),
  );
}

class MedicalicApp extends StatelessWidget {
  const MedicalicApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicalic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;
  final _pages = const [
    HomeScreen(),
    ScheduleScreen(),
    MessageScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _probeApi());
  }

  Future<void> _probeApi() async {
    final api = context.read<ApiService>();
    try {
      final res = await api.getJson('/ping');
      debugPrint('ping ok: $res');
    } catch (e) {
      debugPrint('ping failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
