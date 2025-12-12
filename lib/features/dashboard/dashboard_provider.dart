import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printmax_app/features/dashboard/dashboard_repository.dart';
import 'package:printmax_app/features/dashboard/models/dashboard_summary.dart';
import 'package:printmax_app/features/auth/auth_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final _repo = DashboardRepository();

  bool isLoading = false;
  String? error;
  DashboardSummary? summary;
  DateTimeRange? range;

  void setAuth(AuthProvider auth) {
    // When user is authenticated and we don't have data yet, load once
    if (auth.isAuthenticated && summary == null && !isLoading) {
      fetch();
    }
  }

  Future<void> fetch({DateTimeRange? newRange}) async {
    if (newRange != null) range = newRange;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _repo.fetchSummary(
        from: range?.start,
        to: range?.end,
      );
      summary = res;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

