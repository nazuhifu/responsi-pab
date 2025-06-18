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

  // JSON serialization untuk penyimpanan umum atau transfer data
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
    DateTime parsedDate;
    
    if (addedAtRaw is Timestamp) {
      parsedDate = addedAtRaw.toDate();
    } else if (addedAtRaw is String) {
      parsedDate = DateTime.parse(addedAtRaw);
    } else {
      parsedDate = DateTime.now(); // fallback
    }

    return CartItem(
      id: json['id'] ?? '',
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      addedAt: parsedDate,
    );
  }

  // Untuk disimpan ke Firestore (hanya menyimpan referensi produk)
  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  // Untuk mengambil dari Firestore dengan produk yang sudah diambil terpisah
  factory CartItem.fromFirestore(
    Map<String, dynamic> json, 
    Product fullProduct, {
    String? documentId,
  }) {
    return CartItem(
      id: documentId ?? json['id'] ?? '',
      product: fullProduct,
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] is Timestamp 
        ? (json['addedAt'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }

  // Untuk mengambil dari Firestore tanpa produk lengkap (hanya ID)
  factory CartItem.fromFirestoreMinimal(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return CartItem(
      id: documentId ?? json['id'] ?? '',
      product: Product.empty(id: json['productId'] ?? ''),
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] is Timestamp 
        ? (json['addedAt'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.product == product &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^ product.hashCode ^ quantity.hashCode;
  }

  @override
  String toString() {
    return 'CartItem(id: $id, product: ${product.name}, quantity: $quantity, totalPrice: $totalPrice)';
  }
}