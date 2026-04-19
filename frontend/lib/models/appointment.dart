class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final String date;
  final String? timeSlot;
  final String status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.status,
    this.timeSlot,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] as int,
        patientId: j['patient_id'] as int,
        doctorId: j['doctor_id'] as int,
        date: j['date'] as String,
        timeSlot: j['time_slot'] as String?,
        status: j['status'] as String,
      );
}
