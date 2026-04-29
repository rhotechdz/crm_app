import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/catalog/presentation/providers/products_provider.dart';
import 'package:talabati/features/catalog/presentation/screens/add_edit_product_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final product = products.firstWhere((p) => p.id == productId,
        orElse: () => throw Exception('Product not found'));
    final currencyFormat = NumberFormat.currency(symbol: 'DA');

    final profitMargin = product.sellingPrice > 0
        ? ((product.sellingPrice - product.costPrice) /
                product.sellingPrice *
                100)
            .toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Header
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: product.imageUrl != null
                  ? Image.file(
                      File(product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        product.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (product.description != null) ...[
                            Text(
                              product.description!,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildDetailRow(
                              'Selling Price', currencyFormat.format(product.sellingPrice)),
                          _buildDetailRow(
                              'Cost Price', currencyFormat.format(product.costPrice)),
                          const Divider(),
                          _buildDetailRow('Profit Margin', '$profitMargin%'),
                          const Divider(),
                          _buildDetailRow(
                              'Base Stock',
                              product.stockQuantity?.toString() ??
                                  'Unlimited / Not tracked'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Variants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (product.variants.isEmpty)
                    const Text('No variants for this product')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: product.variants.length,
                      itemBuilder: (context, index) {
                        final variant = product.variants[index];
                        return Card(
                          child: ListTile(
                            title: Text(variant.label),
                            subtitle: Text(
                              'Additional Price: ${currencyFormat.format(variant.additionalPrice)}',
                            ),
                            trailing: Text(
                              'Stock: ${variant.stockQuantity ?? "∞"}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
