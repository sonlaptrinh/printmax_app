import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printmax_app/features/auth/auth_provider.dart';
import 'package:printmax_app/features/dashboard/dashboard_provider.dart';
import 'package:printmax_app/features/dashboard/models/dashboard_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _fmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  Future<void> _pickRange(DashboardProvider p) async {
    final now = DateTime.now();
    final initial = p.range ?? DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
      locale: const Locale('vi'),
    );
    if (picked != null) {
      p.fetch(newRange: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard PrintMax'),
        actions: [
          IconButton(
            tooltip: 'Chọn khoảng thời gian',
            onPressed: () => _pickRange(p),
            icon: const Icon(Icons.date_range),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().fetch(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (p.isLoading && p.summary == null)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )),
            if (p.error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lỗi: ${p.error}', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () => context.read<DashboardProvider>().fetch(),
                        child: const Text('Thử lại'),
                      )
                    ],
                  ),
                ),
              ),
            if (p.summary != null) ...[
              _SummaryCards(summary: p.summary!, fmt: _fmt),
              const SizedBox(height: 16),
              _SeriesChart(series: p.summary!.series),
            ],
            if (!p.isLoading && p.summary == null && p.error == null)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Chưa có dữ liệu'),
              )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<DashboardProvider>().fetch(),
        icon: const Icon(Icons.refresh),
        label: const Text('Làm mới'),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary, required this.fmt});
  final DashboardSummary summary;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 720;
        final children = [
          _StatCard(title: 'Doanh số', value: fmt.format(summary.revenue), color: Colors.blue),
          _StatCard(title: 'Chi phí', value: fmt.format(summary.cost), color: Colors.orange),
          _StatCard(title: 'Lãi lỗ', value: fmt.format(summary.profit), color: summary.profit >= 0 ? Colors.green : Colors.red),
        ];
        if (isWide) {
          return Row(
            children: children
                .map((e) => Expanded(child: Padding(padding: const EdgeInsets.all(8), child: e)))
                .toList(),
          );
        }
        return Column(
          children: children
              .map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: e))
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.color});
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesChart extends StatelessWidget {
  const _SeriesChart({required this.series});
  final List<DashboardPoint> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return const SizedBox();
    }
    series.sort((a, b) => a.date.compareTo(b.date));

    final spotsRevenue = <FlSpot>[];
    final spotsProfit = <FlSpot>[];
    final start = series.first.date.millisecondsSinceEpoch.toDouble();
    for (final p in series) {
      final x = (p.date.millisecondsSinceEpoch.toDouble() - start) / (1000 * 60 * 60 * 24); // days
      spotsRevenue.add(FlSpot(x, p.revenue));
      spotsProfit.add(FlSpot(x, p.profit));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diễn biến doanh số & lãi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      spots: spotsRevenue,
                    ),
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      spots: spotsProfit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

