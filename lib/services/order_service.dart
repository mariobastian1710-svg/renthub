import 'package:rental_marketplace/models/order_item.dart';
import 'package:rental_marketplace/services/api_client.dart';

class OrderService {
  OrderService({required this.api});

  final ApiClient api;

  Future<OrderCreateResult> createOrder({
    required String loginToken,
    required int productId,
    required String startDate,
    required String endDate,
  }) async {
    final json = await api.postJson(
      '/orders',
      loginToken: loginToken,
      body: {
        'product_id': productId,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
    return OrderCreateResult.fromJson(json);
  }

  Future<List<OrderItem>> getHistory({required String loginToken}) async {
    final json = await api.postJson(
      '/orders/history',
      loginToken: loginToken,
      body: const <String, dynamic>{},
    );

    final list = (json['orders'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class OrderCreateResult {
  OrderCreateResult({
    required this.orderId,
    required this.productId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  final int orderId;
  final int productId;
  final int userId;
  final String startDate;
  final String endDate;
  final num totalPrice;
  final String status;

  factory OrderCreateResult.fromJson(Map<String, dynamic> json) {
    return OrderCreateResult(
      orderId: (json['order_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      totalPrice: (json['total_price'] as num?) ?? 0,
      status: (json['status'] ?? '').toString(),
    );
  }
}

