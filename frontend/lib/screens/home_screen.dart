import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../models/health_metric.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/metric_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<_HomeData>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final api = context.read<ApiService>();
    if (!api.isAuthed) {
      final login = await api.postJson('/auth/login', {
        'email': 'demo@medicalic.app',
        'password': 'demo1234',
      });
      api.setAuth(login['access_token'] as String, login['patient_id'] as int);
    }
    final pid = api.patientId!;
    final healthJson = await api.getJson('/health/$pid');
    final snapshot = HealthSnapshot.fromJson(healthJson as Map<String, dynamic>);
    final charts = <String, HealthChart>{};
    for (final type in ['glucose', 'heart_rate', 'cholesterol']) {
      final c = await api.getJson('/health/$pid/chart?metric_type=$type');
      charts[type] = HealthChart.fromJson(c as Map<String, dynamic>);
    }
    final docs = await api.getJson('/doctors');
    final doctors = (docs as List).map((e) => Doctor.fromJson(e)).toList();
    return _HomeData(snapshot: snapshot, charts: charts, featured: doctors.first);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const _LoadingView();
              }
              if (snap.hasError) {
                return _ErrorView(error: snap.error.toString(), onRetry: _refresh);
              }
              final d = snap.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Header(name: 'Jane'),
                  const SizedBox(height: 16),
                  _FeaturedDoctorCard(doctor: d.featured),
                  const SizedBox(height: 20),
                  const Text('Health Metrics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildMetric(d, 'glucose', 'Glucose Level', Icons.bloodtype_outlined,
                      AppTheme.primaryBlue),
                  const SizedBox(height: 12),
                  _buildMetric(d, 'heart_rate', 'Heart Rate', Icons.favorite_rounded,
                      const Color(0xFFE45A84)),
                  const SizedBox(height: 12),
                  _buildMetric(d, 'cholesterol', 'Cholesterol', Icons.monitor_heart_outlined,
                      const Color(0xFFF5A623)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(_HomeData d, String type, String title, IconData icon, Color color) {
    final m = d.snapshot.metrics[type];
    final chart = d.charts[type];
    if (m == null || chart == null) return const SizedBox.shrink();
    return MetricCard(
      title: title,
      value: m.value,
      unit: m.unit,
      chartValues: chart.values,
      accent: color,
      icon: icon,
    );
  }
}

class _HomeData {
  final HealthSnapshot snapshot;
  final Map<String, HealthChart> charts;
  final Doctor featured;
  _HomeData({required this.snapshot, required this.charts, required this.featured});
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $name 👋', style: const TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              const Text('Your Dashboard',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }
}

class _FeaturedDoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _FeaturedDoctorCard({required this.doctor});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              backgroundImage: doctor.avatarUrl != null
                  ? NetworkImage(doctor.avatarUrl!)
                  : null,
              child: doctor.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(doctor.specialty,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text('${doctor.rating}',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_alt_outlined, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text('${doctor.patientCount}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
        const SizedBox(height: 12),
        const Center(
          child: Text('Could not reach backend', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Center(child: Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
        const SizedBox(height: 16),
        Center(child: FilledButton(onPressed: onRetry, child: const Text('Retry'))),
      ],
    );
  }
}
