class DailyTrend {
  final int dayOfWeek; // 1 = Sunday, 7 = Saturday
  final int count;
  final int revenueCents;

  DailyTrend({required this.dayOfWeek, required this.count, required this.revenueCents});

  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    return DailyTrend(
      dayOfWeek: json['_id'],
      count: json['count'],
      revenueCents: json['revenue'],
    );
  }

  String get dayName => ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dayOfWeek - 1];
}