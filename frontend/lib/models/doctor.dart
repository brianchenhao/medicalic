class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String category;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final int patientCount;
  final String? location;
  final String? avatarUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.category,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.patientCount,
    this.location,
    this.avatarUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
        id: j['id'] as int,
        name: j['name'] as String,
        specialty: j['specialty'] as String,
        category: j['category'] as String,
        experienceYears: (j['experience_years'] ?? 0) as int,
        rating: ((j['rating'] ?? 0) as num).toDouble(),
        reviewCount: (j['review_count'] ?? 0) as int,
        patientCount: (j['patient_count'] ?? 0) as int,
        location: j['location'] as String?,
        avatarUrl: j['avatar_url'] as String?,
      );
}
