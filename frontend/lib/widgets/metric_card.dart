import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bar_chart_widget.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final List<double> chartValues;
  final Color accent;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.chartValues,
    this.accent = AppTheme.primaryBlue,
    this.icon = Icons.favorite_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                const Text('View Details',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(unit, style: const TextStyle(color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            BarChartWidget(values: chartValues, color: accent),
          ],
        ),
      ),
    );
  }
}
