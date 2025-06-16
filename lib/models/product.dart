class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final List<String> features;
  final Map<String, String> specifications;
  final bool isInWishlist;
  final bool isInCart;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.features = const [],
    this.specifications = const {},
    this.isInWishlist = false,
    this.isInCart = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    List<String>? images,
    double? rating,
    int? reviewCount,
    int? stock,
    List<String>? features,
    Map<String, String>? specifications,
    bool? isInWishlist,
    bool? isInCart,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      features: features ?? this.features,
      specifications: specifications ?? this.specifications,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      isInCart: isInCart ?? this.isInCart,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'features': features,
      'specifications': specifications,
      'isInWishlist': isInWishlist,
      'isInCart': isInCart,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      stock: json['stock'] ?? 0,
      features: List<String>.from(json['features'] ?? []),
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
      isInWishlist: json['isInWishlist'] ?? false,
      isInCart: json['isInCart'] ?? false,
    );
  }

  /// ✅ Factory ini digunakan saat membaca dari Firebase Firestore
  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stock: data['stock'] ?? 0,
      features: List<String>.from(data['features'] ?? []),
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      isInWishlist: false, // nilai ini bisa diatur di app
      isInCart: false,     // nilai ini juga
    );
  }
}
