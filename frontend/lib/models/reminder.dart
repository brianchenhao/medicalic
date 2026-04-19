class Reminder {
  final int id;
  final int patientId;
  final int? appointmentId;
  final String title;
  final DateTime remindAt;
  final int seen;

  Reminder({
    required this.id,
    required this.patientId,
    required this.title,
    required this.remindAt,
    required this.seen,
    this.appointmentId,
  });

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'] as int,
        patientId: j['patient_id'] as int,
        appointmentId: j['appointment_id'] as int?,
        title: j['title'] as String,
        remindAt: DateTime.parse(j['remind_at'] as String),
        seen: (j['seen'] ?? 0) as int,
      );
}
