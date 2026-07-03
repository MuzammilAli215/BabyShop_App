import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/auth_controller.dart';
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
        builder: (context, productController, _) {
          return RefreshIndicator(
            onRefresh: productController.loadProducts,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(context),
                        const SizedBox(height: 16),
                        _buildSearchField(productController),
                        const SizedBox(height: 16),
                        _buildCategories(productController),
                        const SizedBox(height: 20),
                        _buildSectionHeader(productController),
                      ],
                    ),
                  ),
                ),
                if (productController.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (productController.error != null)
                  SliverFillRemaining(
                    child: _buildMessageState(
                      icon: Icons.error_outline,
                      title: 'Unable to load products',
                      message: productController.error!,
                      actionLabel: 'Try Again',
                      onAction: productController.loadProducts,
                    ),
                  )
                else if (productController.filteredProducts.isEmpty)
                    SliverFillRemaining(
                      child: _buildMessageState(
                        icon: Icons.search_off,
                        title: 'No products found',
                        message: 'Try another category or search keyword.',
                        actionLabel: 'Clear Filters',
                        onAction: () {
                          _searchController.clear();
                          productController.clearFilters();
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final product =
                            productController.filteredProducts[index];
                            return _ProductCard(product: product);
                          },
                          childCount: productController.filteredProducts.length,
                        ),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything your baby needs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Shop diapers, toys, clothes, feeding, care and more.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ProductController productController) {
    return TextField(
      controller: _searchController,
      onChanged: productController.updateSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search products, brands or categories',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: productController.searchQuery.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            _searchController.clear();
            productController.updateSearchQuery('');
          },
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _buildCategories(ProductController productController) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = productController.categories[index];
          final isSelected = category == productController.selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => productController.selectCategory(category),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: productController.categories.length,
      ),
    );
  }

  Widget _buildSectionHeader(ProductController productController) {
    final count = productController.filteredProducts.length;
    return Row(
      children: [
        Text(
          productController.selectedCategory == 'All'
              ? 'Featured Products'
              : productController.selectedCategory,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        Text('$count items', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
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

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: product.image.isEmpty
                    ? Icon(Icons.image, size: 48, color: Colors.grey.shade400)
                    : CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                  ),
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
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(product.avgRating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
