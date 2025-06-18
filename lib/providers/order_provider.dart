import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orders.dart' as model;
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:flutter/foundation.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<model.Order> _orders = [];
  bool _isLoading = false;

  List<model.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<model.Order> loadedOrders = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final itemsRaw = data['items'] as List;

        // Ambil semua productId dari item
        final productIds = itemsRaw.map((item) {
          final productMap = item['product'];
          return productMap != null ? productMap['id'] : null;
        }).whereType<String>().toSet().toList();

        // Ambil data produk dari Firestore
        final productSnapshots = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

        // Map ID → Product
        final productMap = {
          for (var snap in productSnapshots.docs)
            snap.id: Product.fromFirestore(snap.data())
        };

        // Konversi items jadi List<CartItem> dengan produk lengkap
        final cartItems = itemsRaw.map((itemJson) {
          final productJson = itemJson['product'];
          final productId = productJson?['id'] ?? '';
          final product = productMap[productId] ?? Product.empty(id: productId);

          return CartItem(
            id: itemJson['id'] ?? '',
            product: product,
            quantity: itemJson['quantity'] ?? 1,
            addedAt: DateTime.tryParse(itemJson['addedAt'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        // Bangun Order
        final order = model.Order(
          id: doc.id,
          userId: data['userId'],
          items: cartItems,
          totalAmount: (data['totalAmount'] as num).toDouble(),
          shippingCost: (data['shippingCost'] as num).toDouble(),
          status: model.OrderStatus.values.firstWhere(
            (e) => e.toString() == data['status'],
            orElse: () => model.OrderStatus.pending,
          ),
          createdAt: DateTime.parse(data['createdAt']),
          paymentMethod: data['paymentMethod'],
          bankName: data['bankName'],
          shippingAddress: data['shippingAddress'] != null
              ? Map<String, String>.from(data['shippingAddress'])
              : null,
        );

        loadedOrders.add(order);
      }

      _orders = loadedOrders;
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required double shippingCost,
    required String paymentMethod,
    String? bankName,
    Map<String, String>? shippingAddress,
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'shippingCost': shippingCost,
        'status': model.OrderStatus.pending.toString(),
        'createdAt': DateTime.now().toIso8601String(),
        'paymentMethod': paymentMethod,
        'bankName': bankName,
        'shippingAddress': shippingAddress,
      };

      final docRef = await _firestore.collection('orders').add(orderData);
      await loadOrders(userId);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Failed to create order');
    }
  }

  Future<void> updateOrderStatus(String orderId, model.OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString(),
      });

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = model.Order(
          id: _orders[index].id,
          userId: _orders[index].userId,
          items: _orders[index].items,
          totalAmount: _orders[index].totalAmount,
          shippingCost: _orders[index].shippingCost,
          status: status,
          createdAt: _orders[index].createdAt,
          paymentMethod: _orders[index].paymentMethod,
          bankName: _orders[index].bankName,
          shippingAddress: _orders[index].shippingAddress,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      throw Exception('Failed to update order status');
    }
  }
}
