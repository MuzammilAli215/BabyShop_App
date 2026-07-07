class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String brand;
  final String category;
  final String image;
  final int stock;
  final double rating;
  final bool isActive;
  final int totalReviews;
  final double avgRating;

  const ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.brand,
    required this.category,
    required this.image,
    required this.stock,
    required this.rating,
    required this.isActive,
    required this.totalReviews,
    required this.avgRating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String productId) {
    return ProductModel(
      productId: productId,
      name: json['name'] ?? 'N/A',
      description: json['description'] ?? '',
      price: _toDouble(json['price']),
      brand: json['brand'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      image: json['image'] ?? '',
      stock: _toInt(json['stock']),
      rating: _toDouble(json['rating'] ?? json['avgRating']),
      isActive: json['isActive'] ?? true,
      totalReviews: _toInt(json['totalReviews']),
      avgRating: _toDouble(json['avgRating'] ?? json['rating']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool get isInStock => stock > 0;
}
