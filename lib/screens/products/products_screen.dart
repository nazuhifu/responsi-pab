import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../utils/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _sortBy = 'name';
  bool _isGridView = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      final products = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data());
      }).toList();

      setState(() {
        _products = products;
        _filteredProducts = List<Product>.from(products);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal ambil produk dari Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(padding),
                Expanded(
                  child: _isGridView ? _buildGridView(padding) : _buildListView(padding),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Products'),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
      ],
    );
  }

  Widget _buildFilters(double padding) {
    final categories = ['All', ..._extractCategories()];

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _filterProducts();
                  });
                }
              },
            ),
          ),
          SizedBox(width: padding),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: (value) {
        _sortBy = value;
        _sortProducts();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'name', child: Text('Name')),
        const PopupMenuItem(value: 'price_low', child: Text('Price: Low to High')),
        const PopupMenuItem(value: 'price_high', child: Text('Price: High to Low')),
        const PopupMenuItem(value: 'rating', child: Text('Rating')),
      ],
    );
  }

  Widget _buildGridView(double padding) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 4);
        double childAspectRatio =
            (constraints.maxWidth / crossAxisCount) / (constraints.maxHeight * 0.6);

        return GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: padding,
            mainAxisSpacing: padding,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product-detail',
                  arguments: {'productId': product.id},
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListView(double padding) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Card(
          margin: EdgeInsets.only(bottom: padding),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.chair, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.chair, color: Colors.grey),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category),
                if (product.rating > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${product.rating.toStringAsFixed(1)}'),
                    ],
                  ),
              ],
            ),
            trailing: Text(
              '\$${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product-detail',
                arguments: {'productId': product.id},
              );
            },
          ),
        );
      },
    );
  }

  List<String> _extractCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  void _filterProducts() {
    if (_selectedCategory == 'All') {
      _filteredProducts = List<Product>.from(_products);
    } else {
      _filteredProducts =
          _products.where((product) => product.category == _selectedCategory).toList();
    }
    _sortProducts();
  }

  void _sortProducts() {
    switch (_sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    setState(() {});
  }
}
