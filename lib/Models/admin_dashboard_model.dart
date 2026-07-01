class AdminDashboardStats {
  final int totalUsers;
  final int totalOrders;
  final int totalProducts;
  final double revenue;
  final int pendingOrders;
  final int activeProducts;
  final DateTime lastUpdated;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProducts,
    required this.revenue,
    required this.pendingOrders,
    required this.activeProducts,
    required this.lastUpdated,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalOrders': totalOrders,
      'totalProducts': totalProducts,
      'revenue': revenue,
      'pendingOrders': pendingOrders,
      'activeProducts': activeProducts,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
