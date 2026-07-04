import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/auth_controller.dart';
import '../../Controllers/cart_controller.dart';
import '../../Controllers/product_controller.dart';
import '../../Models/product_model.dart';
import '../../Utils/app_theme.dart';
import '../Products/product_details_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductController>().loadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BabyShopHub'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<ProductController>(
        builder: (context, pc, _) {
          return Column(
            children: [
              // ── Always-visible header (never scrolls away) ──
              _PersistentHeader(
                searchController: _searchController,
                productController: pc,
              ),

              // ── Scrollable body ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: pc.loadProducts,
                  child: _buildBody(pc),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ProductController pc) {
    if (pc.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pc.error != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: 'Unable to load products',
        message: pc.error!,
        actionLabel: 'Try Again',
        onAction: pc.loadProducts,
      );
    }

    if (pc.filteredProducts.isEmpty) {
      return _MessageState(
        icon: Icons.search_off,
        title: 'No products found',
        message: 'Try another category or search keyword.',
        actionLabel: 'Clear Filters',
        onAction: () {
          _searchController.clear();
          pc.clearFilters();
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: pc.filteredProducts.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: pc.filteredProducts[index]);
      },
    );
  }
}

// ──────────────────────────────────────────────
// Persistent header — always stays on screen
// ──────────────────────────────────────────────
class _PersistentHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ProductController productController;

  const _PersistentHeader({
    required this.searchController,
    required this.productController,
  });

  @override
  Widget build(BuildContext context) {
    final pc = productController;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Everything your baby needs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Diapers, toys, clothes, feeding & more.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: pc.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search products, brands or categories',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: pc.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          pc.updateSearchQuery('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Category chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pc.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = pc.categories[index];
                final selected = cat == pc.selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => pc.selectCategory(cat),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  pc.selectedCategory == 'All'
                      ? 'Featured Products'
                      : pc.selectedCategory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${pc.filteredProducts.length} items',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Empty / Error state
// ──────────────────────────────────────────────
class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Product Card with cart-awareness
// ──────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cart, _) {
        final inCart = cart.quantityOf(product.productId) > 0;
        final qty = cart.quantityOf(product.productId);

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (inCart) {
              _showAlreadyInCartSheet(context, qty);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              );
            }
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: product.image.isEmpty
                            ? Icon(Icons.image,
                                size: 48, color: Colors.grey.shade400)
                            : CachedNetworkImage(
                                imageUrl: product.image,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                errorWidget: (_, __, ___) => Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              Text(product.avgRating.toStringAsFixed(1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── "In cart" badge overlay ──
                if (inCart)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_cart,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            'x$qty',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
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

  void _showAlreadyInCartSheet(BuildContext context, int qty) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.shopping_cart,
                size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text(
              'Already in your cart',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${product.name} (x$qty) is already in your cart.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    child: const Text('Edit Quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Switch to Cart tab (index 1)
                      // Navigate via named route so MainNavigationScreen handles it
                      Navigator.pushNamed(context, '/cart');
                    },
                    child: const Text('View Cart'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
