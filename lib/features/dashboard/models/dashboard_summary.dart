class DashboardPoint {
  final DateTime date;
  final double revenue;
  final double profit;

  DashboardPoint({required this.date, required this.revenue, required this.profit});

  factory DashboardPoint.fromJson(Map<String, dynamic> json) {
    final d = DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now();
    double toD(v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
    return DashboardPoint(
      date: d,
      revenue: toD(json['revenue']),
      profit: toD(json['profit']),
    );
  }
}

class DashboardSummary {
  final double revenue;
  final double cost;
  final double profit;
  final List<DashboardPoint> series;

  DashboardSummary({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.series,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    double toD(v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
    final list = (json['series'] as List?)?.cast<dynamic>() ?? const [];
    return DashboardSummary(
      revenue: toD(json['revenue']),
      cost: toD(json['cost']),
      profit: toD(json['profit']),
      series: list.whereType<Map<String, dynamic>>().map((e) => DashboardPoint.fromJson(e)).toList(),
    );
  }
}

