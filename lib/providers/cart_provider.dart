import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  final _firestore = FirebaseFirestore.instance;
  final _auth = fb_auth.FirebaseAuth.instance;

  List<CartItem> get items => _items;
  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: '',
        product: Product(id: '', name: '', category: '', price: 0, description: '', images: []),
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  Future<void> loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    _items.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final productId = data['productId'];

      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (productDoc.exists) {
        final product = Product.fromJson(productDoc.data()!..['id'] = productDoc.id);
        final item = CartItem.fromFirestore(data, product, documentId: doc.id);
        _items.add(item);
      }
    }

    notifyListeners();
  }

  Future<void> syncItemToFirestore(CartItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(item.product.id)
        .set(item.toFirestore());
  }

  Future<void> removeItemFromFirestore(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> clearCartFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final cartRef = _firestore.collection('users').doc(user.uid).collection('cart');
    final snapshot = await cartRef.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedItem = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
      _items[existingIndex] = updatedItem;
      await syncItemToFirestore(updatedItem);
    } else {
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      _items.add(newItem);
      await syncItemToFirestore(newItem);
    }

    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await removeItemFromFirestore(productId);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        await removeFromCart(productId);
      } else {
        final updatedItem = _items[index].copyWith(quantity: quantity);
        _items[index] = updatedItem;
        notifyListeners();
        await syncItemToFirestore(updatedItem);
      }
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await clearCartFirestore();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}
