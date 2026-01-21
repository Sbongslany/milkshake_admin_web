
class Order {
  final String id;
  final List<Map<String, dynamic>> drinks;
  final dynamic restaurant; // Can be String (ID) or Map (populated object)
  final DateTime pickupTime;
  final int subtotalCents;
  final int discountPercent;
  final int discountCents;
  final int vatCents;
  final int totalCents;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.drinks,
    this.restaurant,
    required this.pickupTime,
    required this.subtotalCents,
    required this.discountPercent,
    required this.discountCents,
    required this.vatCents,
    required this.totalCents,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String,
      drinks: (json['drinks'] as List).cast<Map<String, dynamic>>(),
      restaurant: json['restaurant'], // Keep as dynamic (String or Map)
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      subtotalCents: json['subtotalCents'] as int? ?? 0,
      discountPercent: json['discountPercent'] as int? ?? 0,
      discountCents: json['discountCents'] as int? ?? 0,
      vatCents: json['vatCents'] as int? ?? 0,
      totalCents: json['totalCents'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get restaurantName {
    if (restaurant is Map<String, dynamic>) {
      return restaurant['name'] ?? 'Unknown Branch';
    }
    return 'Branch'; // Fallback if just ID
  }

  bool get hasDiscount => discountPercent > 0;
}