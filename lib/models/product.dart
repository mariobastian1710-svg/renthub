class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerDay,
    required this.imageUrl,
    required this.category,
    required this.ownerId,
    required this.isAvailable,
  });

  final int id;
  final String name;
  final String description;
  final num pricePerDay;
  final String imageUrl;
  final String category;
  final int ownerId;
  final bool isAvailable;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      pricePerDay: (json['price_per_day'] as num?) ?? 0,
      imageUrl: (json['image_url'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      ownerId: (json['owner_id'] as num?)?.toInt() ?? 0,
      isAvailable: (json['is_available'] as bool?) ?? false,
    );
  }
}

