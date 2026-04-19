import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../theme/app_theme.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;
  const DoctorCard({super.key, required this.doctor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                backgroundImage: doctor.avatarUrl != null ? NetworkImage(doctor.avatarUrl!) : null,
                child: doctor.avatarUrl == null ? const Icon(Icons.person, color: AppTheme.primaryBlue) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(doctor.specialty, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                        const SizedBox(width: 2),
                        Text('${doctor.rating}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 10),
                        Text('${doctor.experienceYears}y exp',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
