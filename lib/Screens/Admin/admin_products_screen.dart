import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/admin_controller.dart';
import '../../Models/admin_product_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminController>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Consumer<AdminController>(
        builder: (context, adminController, _) {
          if (adminController.productsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminController.error != null && adminController.products.isEmpty) {
            return _buildErrorState(adminController.error!, () {
              adminController.clearError();
              adminController.loadProducts();
            });
          }

          if (adminController.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Products Found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: adminController.products.length,
            itemBuilder: (context, index) {
              final product = adminController.products[index];
              return _buildProductCard(context, product, adminController);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddProductDialog(context);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, AdminProductModel product,
      AdminController adminController) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: product.image.isNotEmpty
                      ? Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                            );
                          },
                        )
                      : Icon(
                          Icons.image,
                          color: Colors.grey.shade400,
                        ),
                ),
                const SizedBox(width: 12),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: product.stock > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: Colors.blue,
                  onTap: () {
                    _showEditProductDialog(context, product, adminController);
                  },
                ),
                _buildActionButton(
                  icon: Icons.inventory,
                  label: 'Stock',
                  color: Colors.orange,
                  onTap: () {
                    _showUpdateStockDialog(
                        context, product, adminController);
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () {
                    _showDeleteConfirmation(context, product, adminController);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final brandController = TextEditingController();
    final categoryController = TextEditingController();
    final imageController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Product Name'),
              const SizedBox(height: 12),
              _buildTextField(descriptionController, 'Description',
                  maxLines: 2),
              const SizedBox(height: 12),
              _buildTextField(priceController, 'Price',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(brandController, 'Brand'),
              const SizedBox(height: 12),
              _buildTextField(categoryController, 'Category'),
              const SizedBox(height: 12),
              _buildTextField(imageController, 'Image URL'),
              const SizedBox(height: 12),
              _buildTextField(stockController, 'Stock',
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final product = AdminProductModel(
                productId: '',
                name: nameController.text,
                description: descriptionController.text,
                price: double.parse(priceController.text),
                brand: brandController.text,
                category: categoryController.text,
                image: imageController.text,
                stock: int.parse(stockController.text),
                rating: 0,
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                totalReviews: 0,
                avgRating: 0,
              );
              context.read<AdminController>().addProduct(product);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, AdminProductModel product,
      AdminController adminController) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController =
        TextEditingController(text: product.description);
    final priceController =
        TextEditingController(text: product.price.toString());
    final brandController = TextEditingController(text: product.brand);
    final categoryController = TextEditingController(text: product.category);
    final imageController = TextEditingController(text: product.image);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Product Name'),
              const SizedBox(height: 12),
              _buildTextField(descriptionController, 'Description',
                  maxLines: 2),
              const SizedBox(height: 12),
              _buildTextField(priceController, 'Price',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(brandController, 'Brand'),
              const SizedBox(height: 12),
              _buildTextField(categoryController, 'Category'),
              const SizedBox(height: 12),
              _buildTextField(imageController, 'Image URL'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProduct = AdminProductModel(
                productId: product.productId,
                name: nameController.text,
                description: descriptionController.text,
                price: double.parse(priceController.text),
                brand: brandController.text,
                category: categoryController.text,
                image: imageController.text,
                stock: product.stock,
                rating: product.rating,
                isActive: product.isActive,
                createdAt: product.createdAt,
                updatedAt: DateTime.now(),
                totalReviews: product.totalReviews,
                avgRating: product.avgRating,
              );
              adminController.updateProduct(product.productId, updatedProduct);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, AdminProductModel product,
      AdminController adminController) {
    final stockController = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: _buildTextField(stockController, 'New Stock',
            keyboardType: TextInputType.number),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              adminController.updateProductStock(
                product.productId,
                int.parse(stockController.text),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AdminProductModel product,
      AdminController adminController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              adminController.deleteProduct(product.productId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Unable to load data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
