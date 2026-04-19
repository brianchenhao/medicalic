class HealthSnapshot {
  final int patientId;
  final Map<String, MetricValue> metrics;
  HealthSnapshot({required this.patientId, required this.metrics});

  factory HealthSnapshot.fromJson(Map<String, dynamic> j) {
    final raw = (j['metrics'] as Map<String, dynamic>?) ?? {};
    final m = raw.map((k, v) => MapEntry(k, MetricValue.fromJson(v as Map<String, dynamic>)));
    return HealthSnapshot(patientId: j['patient_id'] as int, metrics: m);
  }
}

class MetricValue {
  final double value;
  final String unit;
  MetricValue({required this.value, required this.unit});
  factory MetricValue.fromJson(Map<String, dynamic> j) => MetricValue(
        value: (j['value'] as num).toDouble(),
        unit: j['unit'] as String,
      );
}

class HealthChart {
  final String metricType;
  final List<double> values;
  final String? unit;
  HealthChart({required this.metricType, required this.values, this.unit});

  factory HealthChart.fromJson(Map<String, dynamic> j) => HealthChart(
        metricType: j['metric_type'] as String,
        values: ((j['values'] as List?) ?? []).map((e) => (e as num).toDouble()).toList(),
        unit: j['unit'] as String?,
      );
}
