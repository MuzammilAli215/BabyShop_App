class AdminOrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  AdminOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? 'N/A',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class AdminOrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final List<AdminOrderItem> items;
  final double totalPrice;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? shippingAddress;
  final String? trackingNumber;

  AdminOrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.shippingAddress,
    this.trackingNumber,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json, String orderId) {
    return AdminOrderModel(
      orderId: orderId,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'N/A',
      userEmail: json['userEmail'] ?? 'N/A',
      items: (json['items'] as List?)
          ?.map((item) => AdminOrderItem.fromJson(item))
          .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'N/A',
      status: _parseOrderStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      shippingAddress: json['shippingAddress'],
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
    };
  }

  static OrderStatus _parseOrderStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    return status.toString().split('.').last;
  }

  String get statusDisplayString {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
