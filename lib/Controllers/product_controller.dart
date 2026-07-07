import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/product_model.dart';

class ProductController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSubscription;

  final List<String> categories = const [
    'All',
    'Diapers',
    'Baby Food',
    'Toys',
    'Clothes',
    'Baby Care',
    'Feeding',
    'Bath',
    'Accessories',
  ];

  List<ProductModel> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> loadProducts() async {
    _productsSubscription ??= _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
        _products = snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _error = 'Error loading products: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );

    if (_products.isEmpty) {
      _isLoading = true;
      _error = null;
      notifyListeners();

    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  ProductModel? findById(String productId) {
    try {
      return _products.firstWhere((product) => product.productId == productId);
    } catch (_) {
      return null;
    }
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
  }
  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
