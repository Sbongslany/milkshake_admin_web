class Consistency {
  final String id;
  final String name;
  final int price;
  final bool active;

  Consistency({required this.id, required this.name, required this.price, this.active = true});

  factory Consistency.fromJson(Map<String, dynamic> json) {
    return Consistency(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}