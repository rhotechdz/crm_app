import 'package:uuid/uuid.dart';
import 'product_variant.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final double sellingPrice;
  final double costPrice;
  final List<ProductVariant> variants;
  final int? stockQuantity;
  final String? imageUrl;
  final DateTime createdAt;

  Product({
    String? id,
    required this.name,
    this.description,
    required this.sellingPrice,
    required this.costPrice,
    this.variants = const [],
    this.stockQuantity,
    this.imageUrl,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, List<ProductVariant> variants) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      sellingPrice: map['sellingPrice'],
      costPrice: map['costPrice'],
      variants: variants,
      stockQuantity: map['stockQuantity'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
