import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../Models/product_model.dart';
import '../../Utils/app_theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.15,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: product.image.isEmpty
                    ? Icon(Icons.image, size: 90, color: Colors.grey.shade400)
                    : CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      _buildStockBadge(product),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        product.avgRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(' (${product.totalReviews} reviews)'),
                      const Spacer(),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'No description available for this product.'
                        : product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text('Quantity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          _quantity.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      _quantityButton(
                        icon: Icons.add,
                        onPressed: _quantity < product.stock
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                      const Spacer(),
                      Text('${product.stock} in stock'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: product.isInStock
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${product.name} x$_quantity will be added to cart in the next phase.',
                  ),
                ),
              );
            }
                : null,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Add to Cart'),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(ProductModel product) {
    final inStock = product.isInStock;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: inStock ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: TextStyle(
          color: inStock ? Colors.green.shade800 : Colors.red.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 42,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon),
      ),
    );
  }
}
