import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/formatter.dart';
import 'dart:convert';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 180;
        final titleFontSize = isWide ? 14.0 : 12.0;
        final priceFontSize = isWide ? 16.0 : 14.0;

        return Card(
          margin: const EdgeInsets.only(right: 12, bottom: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImage(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCategory(),
                              const SizedBox(height: 4),
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              _buildRating(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatRupiah(product.price),
                          style: TextStyle(
                            fontSize: priceFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showAddToCart) ...[
                          const SizedBox(height: 8),
                          _buildActions(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    Widget imageWidget;

    if (product.images.isNotEmpty) {
      final image = product.images.first;

      if (image.startsWith('data:image')) {
        try {
          final base64Str = image.split(',').last;
          final bytes = base64Decode(base64Str);
          imageWidget = Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.chair, size: 40, color: Colors.grey);
            },
          );
        } catch (_) {
          imageWidget = const Icon(Icons.chair, size: 40, color: Colors.grey);
        }
      } else {
        imageWidget = Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.chair, size: 40, color: Colors.grey);
          },
        );
      }
    } else {
      imageWidget = const Icon(Icons.chair, size: 40, color: Colors.grey);
    }

    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Consumer<WishlistProvider>(
            builder: (context, wishlist, child) {
              final isInWishlist = wishlist.isInWishlist(product.id);
              return GestureDetector(
                onTap: () {
                  wishlist.toggleWishlist(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isInWishlist
                            ? 'Removed from wishlist'
                            : 'Added to wishlist',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return Text(
      product.category,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _buildRating() {
    if (product.rating == 0) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          product.rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          ' (${product.reviewCount})',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              cart.addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text('Add to Cart'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
