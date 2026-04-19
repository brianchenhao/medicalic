import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;
  const BarChartWidget({
    super.key,
    required this.values,
    this.color = AppTheme.primaryBlue,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height);
    }
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final span = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            Expanded(
              child: FractionallySizedBox(
                heightFactor: 0.25 + 0.75 * ((values[i] - minV) / span),
                child: Container(
                  decoration: BoxDecoration(
                    color: i == values.length - 1 ? color : color.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            if (i != values.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}
