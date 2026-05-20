import 'package:rental_marketplace/models/product.dart';
import 'package:rental_marketplace/models/product_detail.dart';
import 'package:rental_marketplace/services/api_client.dart';

class ProductService {
  ProductService({required this.api});

  final ApiClient api;

  Future<ProductDetail> getProductById({
    required String loginToken,
    required int id,
  }) async {
    final json = await api.postJson(
      '/products/$id',
      loginToken: loginToken,
      body: const <String, dynamic>{},
    );
    return ProductDetail.fromJson(json);
  }

  Future<List<Product>> getProducts({
    required String loginToken,
    String? category,
    String? searchQuery,
  }) async {
    final body = <String, dynamic>{};
    if (category != null && category.isNotEmpty) body['category'] = category;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      body['search_query'] = searchQuery;
    }

    final json = await api.postJson(
      '/products',
      loginToken: loginToken,
      body: body,
    );

    final list = (json['products'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

