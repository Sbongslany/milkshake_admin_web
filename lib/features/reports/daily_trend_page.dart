
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/api_service.dart';
import '../../models/daily_trend.dart';

final dailyTrendProvider = FutureProvider<List<DailyTrend>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final dynamic rawData = await api.get('reports/daily-trend');

  if (rawData is! List) {
    throw Exception('Expected list of daily trends');
  }

  return rawData.map<DailyTrend>((j) => DailyTrend.fromJson(j as Map<String, dynamic>)).toList();
});

class DailyTrendPage extends ConsumerWidget {
  const DailyTrendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(dailyTrendProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: trendAsync.when(
          data: (trends) {
            final allTrends = List.generate(7, (index) {
              final dayNum = index + 1;
              return trends.firstWhere(
                    (t) => t.dayOfWeek == dayNum,
                orElse: () => DailyTrend(dayOfWeek: dayNum, count: 0, revenueCents: 0),
              );
            });

            return _buildDashboard(allTrends);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text('Error loading daily trend', style: TextStyle(color: Colors.red, fontSize: 16)),
                Text('$e', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(dailyTrendProvider),
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(List<DailyTrend> trends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Trends',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weekly order and revenue patterns',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    'Last 7 Days',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Orders',
                value: trends.map((t) => t.count).reduce((a, b) => a + b).toString(),
                icon: Icons.shopping_cart,
                color: Colors.blue,
                trend: _calculateTrend(trends, 'orders'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Revenue',
                value: 'R${(trends.map((t) => t.revenueCents).reduce((a, b) => a + b) / 100).toStringAsFixed(2)}',
                icon: Icons.monetization_on,
                color: Colors.green,
                trend: _calculateTrend(trends, 'revenue'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Average/Day',
                value: (trends.map((t) => t.count).reduce((a, b) => a + b) / 7).toStringAsFixed(1),
                icon: Icons.trending_up,
                color: Colors.purple,
                trend: _calculateTrend(trends, 'average'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Line Chart
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Orders per day',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200],
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt() - 1;
                              if (index >= 0 && index < trends.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    trends[index].dayName.substring(0, 3),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      minX: 1,
                      maxX: 7,
                      minY: 0,
                      maxY: _getMaxY(trends).toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trends.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final trend = entry.value;
                            return FlSpot(index.toDouble(), trend.count.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue,
                                  strokeWidth: 0,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Number of Orders',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),


      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: trend.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTrend(List<DailyTrend> trends, String type) {
    if (trends.length < 2) return '+0%';

    double firstHalf = 0;
    double secondHalf = 0;
    int mid = trends.length ~/ 2;

    if (type == 'orders') {
      firstHalf = trends.sublist(0, mid).map((t) => t.count).reduce((a, b) => a + b) / mid;
      secondHalf = trends.sublist(mid).map((t) => t.count).reduce((a, b) => a + b) / (trends.length - mid);
    } else if (type == 'revenue') {
      firstHalf = trends.sublist(0, mid).map((t) => t.revenueCents).reduce((a, b) => a + b) / mid;
      secondHalf = trends.sublist(mid).map((t) => t.revenueCents).reduce((a, b) => a + b) / (trends.length - mid);
    } else {
      // average
      final firstHalfAvg = trends.sublist(0, mid).map((t) => t.count).reduce((a, b) => a + b) / mid;
      final secondHalfAvg = trends.sublist(mid).map((t) => t.count).reduce((a, b) => a + b) / (trends.length - mid);
      firstHalf = firstHalfAvg;
      secondHalf = secondHalfAvg;
    }

    if (firstHalf == 0) return secondHalf == 0 ? '0%' : '+100%';

    final percentage = ((secondHalf - firstHalf) / firstHalf * 100).toInt();
    return '${percentage >= 0 ? '+' : ''}$percentage%';
  }

  double _getMaxY(List<DailyTrend> trends) {
    final maxCount = trends.map((t) => t.count).reduce((a, b) => a > b ? a : b);
    // Round up to nearest 5 for better chart scaling
    return (maxCount + 5).toDouble();
  }

  int _getMaxCount(List<DailyTrend> trends) {
    final maxCount = trends.map((t) => t.count).reduce((a, b) => a > b ? a : b);
    return maxCount == 0 ? 1 : maxCount;
  }
}