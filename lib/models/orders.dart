import 'cart_item.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final double shippingCost;
  final OrderStatus status;
  final DateTime createdAt;
  final String? paymentMethod;
  final String? bankName;
  final Map<String, String>? shippingAddress;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingCost,
    required this.status,
    required this.createdAt,
    this.paymentMethod,
    this.bankName,
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'shippingCost': shippingCost,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'bankName': bankName,
      'shippingAddress': shippingAddress,
    };
  }

  factory Order.fromJson(String id, Map<String, dynamic> json) {
    return Order(
      id: id,
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      paymentMethod: json['paymentMethod'],
      bankName: json['bankName'],
      shippingAddress: json['shippingAddress'] != null
          ? Map<String, String>.from(json['shippingAddress'])
          : null,
    );
  }
}