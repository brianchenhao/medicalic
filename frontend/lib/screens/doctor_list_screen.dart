import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_tabs.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  static const _categories = ['Doctors', 'Therm', 'EHR'];
  String _selected = 'Doctors';
  String _query = '';
  Future<List<Doctor>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load(_selected);
  }

  Future<List<Doctor>> _load(String cat) async {
    final api = context.read<ApiService>();
    final res = await api.getJson('/doctors?category=$cat');
    return (res as List).map((e) => Doctor.fromJson(e)).toList();
  }

  void _onTab(String c) {
    setState(() {
      _selected = c;
      _future = _load(c);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Doctor')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search doctors by name or specialty',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: CategoryTabs(
              categories: _categories,
              selected: _selected,
              onSelected: _onTab,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Failed: ${snap.error}'));
                }
                var docs = snap.data ?? const <Doctor>[];
                if (_query.isNotEmpty) {
                  docs = docs.where((d) =>
                      d.name.toLowerCase().contains(_query) ||
                      d.specialty.toLowerCase().contains(_query)).toList();
                }
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No doctors match', style: TextStyle(color: AppTheme.textMuted)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => DoctorCard(
                    doctor: docs[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: docs[i])),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
