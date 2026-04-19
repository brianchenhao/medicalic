import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/calendar_widget.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DateTime? _selected;
  Set<DateTime> _booked = {};
  List<Reminder> _reminders = [];
  bool _loadingBooked = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadBooked();
  }

  Future<void> _loadBooked() async {
    final api = context.read<ApiService>();
    try {
      final list = await api.getJson('/appointments/${api.patientId}');
      final rems = await api.getJson('/reminders/${api.patientId}');
      final appts = (list as List).map((e) => Appointment.fromJson(e)).toList();
      setState(() {
        _booked = appts
            .where((a) => a.doctorId == widget.doctor.id && a.status == 'booked')
            .map((a) {
          final parts = a.date.split('-');
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }).toSet();
        _reminders = (rems as List)
            .map((e) => Reminder.fromJson(e))
            .where((r) => r.title.contains(widget.doctor.name))
            .toList();
        _loadingBooked = false;
      });
    } catch (_) {
      setState(() => _loadingBooked = false);
    }
  }

  Future<void> _confirmBook() async {
    if (_selected == null) return;
    final d = _selected!;
    final dateStr = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ConfirmSheet(doctor: widget.doctor, date: dateStr),
    );
    if (ok != true) return;
    setState(() => _submitting = true);
    final api = context.read<ApiService>();
    try {
      await api.postJson('/appointments', {
        'doctor_id': widget.doctor.id,
        'date': dateStr,
        'time_slot': '10:00 AM',
      });
      try {
        await api.postJson('/reminders', {
          'title': 'Appointment with ${widget.doctor.name}',
          'remind_at': '${dateStr}T09:00:00',
        });
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booked ${widget.doctor.name} on $dateStr')),
      );
      setState(() {
        _booked = {..._booked, d};
        _selected = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.status == 409 ? 'Slot already booked' : 'Booking failed')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    return Scaffold(
      appBar: AppBar(title: Text(d.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.darkCard,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white24,
                    backgroundImage: d.avatarUrl != null ? NetworkImage(d.avatarUrl!) : null,
                    child: d.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(d.specialty, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        if (d.location != null)
                          Text(d.location!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(label: 'Experience', value: '${d.experienceYears}y'),
              const SizedBox(width: 10),
              _Stat(label: 'Rating', value: '${d.rating}'),
              const SizedBox(width: 10),
              _Stat(label: 'Patients', value: '${d.patientCount}'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Select a date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (_loadingBooked)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else
            CalendarWidget(
              initialMonth: DateTime.now(),
              selected: _selected,
              bookedDates: _booked,
              onSelect: (d) => setState(() => _selected = d),
            ),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          const Text('Doctor Reminders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (_reminders.isEmpty)
            const Text('No reminders for this doctor yet',
                style: TextStyle(color: AppTheme.textMuted))
          else
            for (final r in _reminders)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryBlue),
                  title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${r.remindAt.year}-${r.remindAt.month.toString().padLeft(2, '0')}-${r.remindAt.day.toString().padLeft(2, '0')} '
                      '${r.remindAt.hour.toString().padLeft(2, '0')}:${r.remindAt.minute.toString().padLeft(2, '0')}'),
                ),
              ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selected == null || _submitting ? null : _confirmBook,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_selected == null ? 'Pick a date' : 'Book appointment'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final Doctor doctor;
  final String date;
  const _ConfirmSheet({required this.doctor, required this.date});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confirm booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${doctor.name} • ${doctor.specialty}',
              style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text('Date: $date at 10:00 AM'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
