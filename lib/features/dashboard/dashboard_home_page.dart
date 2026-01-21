// Step 1: Create a new file for Dashboard Home Content
// lib/features/dashboard/dashboard_home_page.dart (New File)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/daily_trend.dart';
import '../reports/daily_trend_page.dart'; // Reuse provider
import '../lookups/flavour_page.dart';
import '../lookups/topping_page.dart';
import '../lookups/consistency_page.dart';
import '../lookups/restaurant_page.dart';

class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTrendAsync = ref.watch(dailyTrendProvider);
    final flavoursAsync = ref.watch(flavourProvider);
    final toppingsAsync = ref.watch(toppingProvider);
    final consistenciesAsync = ref.watch(consistencyProvider);
    final restaurantsAsync = ref.watch(restaurantProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Summary Cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildSummaryCard(
                title: 'Active Flavours',
                value: flavoursAsync.when(
                  data: (f) => f.where((e) => e.active).length.toString(),
                  loading: () => '...',
                  error: (_, __) => 'Error',
                ),
                icon: Icons.icecream,
                color: Colors.purple,
              ),
              _buildSummaryCard(
                title: 'Active Toppings',
                value: toppingsAsync.when(
                  data: (t) => t.where((e) => e.active).length.toString(),
                  loading: () => '...',
                  error: (_, __) => 'Error',
                ),
                icon: Icons.spa_outlined,
                color: Colors.blue,
              ),
              _buildSummaryCard(
                title: 'Consistencies',
                value: consistenciesAsync.when(
                  data: (c) => c.length.toString(),
                  loading: () => '...',
                  error: (_, __) => 'Error',
                ),
                icon: Icons.texture,
                color: Colors.green,
              ),
              _buildSummaryCard(
                title: 'Restaurants',
                value: restaurantsAsync.when(
                  data: (r) => r.where((e) => e.active).length.toString(),
                  loading: () => '...',
                  error: (_, __) => 'Error',
                ),
                icon: Icons.store,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text('Sales Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          dailyTrendAsync.when(
            data: (trends) {
              final allTrends = List.generate(7, (i) {
                final day = i + 1;
                return trends.firstWhere(
                      (t) => t.dayOfWeek == day,
                  orElse: () => DailyTrend(dayOfWeek: day, count: 0, revenueCents: 0),
                );
              });

              final totalOrders = allTrends.fold(0, (sum, t) => sum + t.count);
              final totalRevenue = allTrends.fold(0, (sum, t) => sum + t.revenueCents);

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Orders (All Time)',
                          value: totalOrders.toString(),
                          icon: Icons.shopping_cart,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Revenue (All Time)',
                          value: 'R${(totalRevenue / 100).toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Orders by Day of Week', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                                return Text(days[value.toInt()]);
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: allTrends.asMap().entries.map((entry) {
                          final index = entry.key;
                          final t = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: t.count.toDouble(),
                                color: Colors.purple,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }).toList(),
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}