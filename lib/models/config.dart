class DiscountTier {
  final int minPastOrders;
  final int discountPercent;

  DiscountTier({required this.minPastOrders, required this.discountPercent});

  factory DiscountTier.fromJson(Map<String, dynamic> json) {
    return DiscountTier(
      minPastOrders: json['minPastOrders'],
      discountPercent: json['discountPercent'],
    );
  }

  Map<String, dynamic> toJson() => {
    'minPastOrders': minPastOrders,
    'discountPercent': discountPercent,
  };
}

class Config {
  final int vatRate;
  final int minDrinks;
  final int maxDrinks;
  final List<DiscountTier> discountTiers;
  final int maxDiscountPercent;

  Config({
    required this.vatRate,
    required this.minDrinks,
    required this.maxDrinks,
    required this.discountTiers,
    required this.maxDiscountPercent,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      vatRate: json['vatRate'] ?? 15,
      minDrinks: json['minDrinks'] ?? 1,
      maxDrinks: json['maxDrinks'] ?? 10,
      discountTiers: (json['discountTiers'] as List? ?? [])
          .map((t) => DiscountTier.fromJson(t))
          .toList(),
      maxDiscountPercent: json['maxDiscountPercent'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
    'vatRate': vatRate,
    'minDrinks': minDrinks,
    'maxDrinks': maxDrinks,
    'discountTiers': discountTiers.map((t) => t.toJson()).toList(),
    'maxDiscountPercent': maxDiscountPercent,
  };
}