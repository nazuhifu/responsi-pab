import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];

  final _firestore = FirebaseFirestore.instance;
  final _auth = fb_auth.FirebaseAuth.instance;

  List<Product> get items => _items;
  int get itemCount => _items.length;

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  Future<void> loadWishlistFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .get();

    _items.clear();

    for (var doc in snapshot.docs) {
      final productData = doc.data();
      productData['id'] = doc.id;
      final product = Product.fromJson(productData);
      _items.add(product);
    }

    notifyListeners();
  }

  Future<void> addToWishlist(Product product) async {
    if (isInWishlist(product.id)) return;

    final user = _auth.currentUser;
    if (user == null) return;

    _items.add(product);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(product.id)
        .set(product.toJson());
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _items.removeWhere((item) => item.id == productId);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  Future<void> toggleWishlist(Product product) async {
    if (isInWishlist(product.id)) {
      await removeFromWishlist(product.id);
    } else {
      await addToWishlist(product);
    }
  }

  Future<void> clearWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final wishlistRef = _firestore.collection('users').doc(user.uid).collection('wishlist');
    final snapshot = await wishlistRef.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    _items.clear();
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}
