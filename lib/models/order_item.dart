class OrderItem {
  OrderItem({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  final int orderId;
  final int productId;
  final String productName;
  final String startDate;
  final String endDate;
  final num totalPrice;
  final String status;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: (json['order_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      productName: (json['product_name'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      totalPrice: (json['total_price'] as num?) ?? 0,
      status: (json['status'] ?? '').toString(),
    );
  }
}

