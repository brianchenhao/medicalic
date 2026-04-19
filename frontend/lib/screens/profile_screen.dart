import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.darkCard,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Jane Doe',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('demo@medicalic.app',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(api.isAuthed ? 'Patient ID: ${api.patientId}' : 'Not signed in',
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Row(icon: Icons.person_outline, label: 'Personal information', onTap: () {}),
          _Row(icon: Icons.medical_information_outlined, label: 'Medical records', onTap: () {}),
          _Row(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () {}),
          _Row(icon: Icons.lock_outline, label: 'Privacy & security', onTap: () {}),
          _Row(icon: Icons.help_outline, label: 'Help & support', onTap: () {}),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            onPressed: () {
              setState(() => api.clearAuth());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out — restart app to sign back in')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Row({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
