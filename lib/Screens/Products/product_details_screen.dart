import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/cart_controller.dart';
import '../../Models/product_model.dart';
import '../../Utils/app_theme.dart';
import 'reviews_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Pre-fill quantity from whatever is already in the cart
    final cartQty = context
        .read<CartController>()
        .quantityOf(widget.product.productId);
    if (cartQty > 0) _quantity = cartQty;
  }

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
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(product: product),
                          ),
                        ),
                        child: Text(
                          ' (${product.totalReviews} reviews)',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
          child: Consumer<CartController>(
            builder: (context, cart, _) {
              final alreadyInCart = cart.quantityOf(product.productId) > 0;
              return ElevatedButton.icon(
                onPressed: product.isInStock ? _addToCart : null,
                icon: Icon(alreadyInCart
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined),
                label: Text(alreadyInCart ? 'Update Cart' : 'Add to Cart'),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    final product = widget.product;
    final cart = context.read<CartController>();
    final wasInCart = cart.quantityOf(product.productId) > 0;

    if (wasInCart) {
      // Show confirmation sheet before updating
      _showUpdateConfirmSheet(cart, product);
      return;
    }

    await cart.setQuantity(product, _quantity);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} x$_quantity added to cart.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUpdateConfirmSheet(CartController cart, ProductModel product) {
    final currentQty = cart.quantityOf(product.productId);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.shopping_cart,
                size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text('Already in your cart',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'You have $currentQty of this item in your cart.\n'
                  'Update to $_quantity?',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await cart.setQuantity(product, _quantity);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            '${product.name} updated to x$_quantity in cart.'),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    child: const Text('Update Cart'),
                  ),
                ),
              ],
            ),
          ],
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
