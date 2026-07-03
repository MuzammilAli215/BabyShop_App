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
      price: (json['price'] ?? 0).toDouble(),
      brand: json['brand'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      image: json['image'] ?? '',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? json['avgRating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      totalReviews: json['totalReviews'] ?? 0,
      avgRating: (json['avgRating'] ?? json['rating'] ?? 0).toDouble(),
    );
  }

  bool get isInStock => stock > 0;
}