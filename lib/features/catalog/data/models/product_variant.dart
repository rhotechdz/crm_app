class ProductVariant {
  final String id;
  final String label;
  final double additionalPrice;
  final int? stockQuantity;

  ProductVariant({
    required this.id,
    required this.label,
    this.additionalPrice = 0,
    this.stockQuantity,
  });

  Map<String, dynamic> toMap(String productId) {
    return {
      'id': id,
      'productId': productId,
      'label': label,
      'additionalPrice': additionalPrice,
      'stockQuantity': stockQuantity,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'],
      label: map['label'],
      additionalPrice: map['additionalPrice']?.toDouble() ?? 0.0,
      stockQuantity: map['stockQuantity'],
    );
  }
}
