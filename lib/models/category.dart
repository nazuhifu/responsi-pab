import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.productCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productCount': productCount,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: Icons.category, // Default icon
      productCount: json['productCount'] ?? 0,
    );
  }
}
