import 'package:rental_marketplace/models/product.dart';

class ProductDetail extends Product {
  ProductDetail({
    required super.id,
    required super.name,
    required super.description,
    required super.pricePerDay,
    required super.imageUrl,
    required super.category,
    required super.ownerId,
    required super.isAvailable,
    required this.ownerUsername,
  });

  final String ownerUsername;

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final base = Product.fromJson(json);
    return ProductDetail(
      id: base.id,
      name: base.name,
      description: base.description,
      pricePerDay: base.pricePerDay,
      imageUrl: base.imageUrl,
      category: base.category,
      ownerId: base.ownerId,
      isAvailable: base.isAvailable,
      ownerUsername: (json['owner_username'] ?? '').toString(),
    );
  }
}

