import 'product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final addedAtRaw = json['addedAt'];
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      addedAt: addedAtRaw is Timestamp
          ? addedAtRaw.toDate()
          : DateTime.parse(addedAtRaw),
    );
  }

  /// Untuk disimpan ke Firestore (tidak menyimpan full produk)
  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Untuk mengambil dari Firestore + ambil `Product` secara terpisah
  factory CartItem.fromFirestore(
      Map<String, dynamic> json, Product fullProduct) {
    return CartItem(
      id: json['id'],
      product: fullProduct,
      quantity: json['quantity'],
      addedAt: (json['addedAt'] as Timestamp).toDate(),
    );
  }
}
