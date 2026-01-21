class Restaurant {
  final String id;
  final String name;
  final String address;
  final bool active;

  Restaurant({required this.id, required this.name, required this.address, this.active = true});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'address': address};
}