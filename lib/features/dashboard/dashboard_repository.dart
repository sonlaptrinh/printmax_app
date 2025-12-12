import 'package:printmax_app/core/api_client.dart';
import 'package:printmax_app/features/dashboard/models/dashboard_summary.dart';

class DashboardRepository {
  Future<DashboardSummary> fetchSummary({DateTime? from, DateTime? to}) async {
    final res = await ApiClient.instance.get(
      '/dashboard/summary',
      query: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return DashboardSummary.fromJson(data);
    }
    throw Exception('Dữ liệu dashboard không hợp lệ');
  }
}

