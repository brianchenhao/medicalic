import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Future<_ScheduleData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ScheduleData> _load() async {
    final api = context.read<ApiService>();
    if (!api.isAuthed) {
      final login = await api.postJson('/auth/login', {
        'email': 'demo@medicalic.app',
        'password': 'demo1234',
      });
      api.setAuth(login['access_token'] as String, login['patient_id'] as int);
    }
    final pid = api.patientId!;
    final appts = await api.getJson('/appointments/$pid');
    final rems = await api.getJson('/reminders/$pid');
    return _ScheduleData(
      appointments: (appts as List).map((e) => Appointment.fromJson(e)).toList(),
      reminders: (rems as List).map((e) => Reminder.fromJson(e)).toList(),
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _cancel(Appointment a) async {
    final api = context.read<ApiService>();
    try {
      await api.deleteJson('/appointments/${a.id}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')),
      );
      _refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_ScheduleData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [
                const SizedBox(height: 120),
                Center(child: Text('Error: ${snap.error}')),
              ]);
            }
            final d = snap.data!;
            final upcoming = d.appointments.where((a) => a.status == 'booked').toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Upcoming appointments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  const Text('No upcoming appointments',
                      style: TextStyle(color: AppTheme.textMuted)),
                for (final a in upcoming)
                  _AppointmentTile(appointment: a, onCancel: () => _cancel(a)),
                const SizedBox(height: 24),
                const Text('Reminders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (d.reminders.isEmpty)
                  const Text('No reminders yet',
                      style: TextStyle(color: AppTheme.textMuted)),
                for (final r in d.reminders) _ReminderTile(reminder: r),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleData {
  final List<Appointment> appointments;
  final List<Reminder> reminders;
  _ScheduleData({required this.appointments, required this.reminders});
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onCancel;
  const _AppointmentTile({required this.appointment, required this.onCancel});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
          child: const Icon(Icons.event_outlined, color: AppTheme.primaryBlue),
        ),
        title: Text('Doctor #${appointment.doctorId}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${appointment.date}${appointment.timeSlot != null ? ' • ${appointment.timeSlot}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
          onPressed: onCancel,
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  const _ReminderTile({required this.reminder});
  @override
  Widget build(BuildContext context) {
    final d = reminder.remindAt;
    final pretty = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF5A623).withValues(alpha: 0.15),
          child: const Icon(Icons.notifications_none_rounded, color: Color(0xFFF5A623)),
        ),
        title: Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(pretty),
      ),
    );
  }
}
