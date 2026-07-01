class AdminProductModel {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalReviews;
  final double avgRating;

  AdminProductModel({
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
    required this.createdAt,
    required this.updatedAt,
    required this.totalReviews,
    required this.avgRating,
  });

  factory AdminProductModel.fromJson(Map<String, dynamic> json, String productId) {
    return AdminProductModel(
      productId: productId,
      name: json['name'] ?? 'N/A',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      brand: json['brand'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      image: json['image'] ?? '',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      totalReviews: json['totalReviews'] ?? 0,
      avgRating: (json['avgRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'brand': brand,
      'category': category,
      'image': image,
      'stock': stock,
      'rating': rating,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalReviews': totalReviews,
      'avgRating': avgRating,
    };
  }
}
