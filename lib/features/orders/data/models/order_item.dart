class OrderItem {
  final String productId;
  final String productName;
  final String? variantLabel;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    this.variantLabel,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap(String orderId) {
    return {
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'variantLabel': variantLabel,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      productName: map['productName'],
      variantLabel: map['variantLabel'],
      quantity: map['quantity'],
      unitPrice: (map['unitPrice'] as num).toDouble(),
    );
  }
}
