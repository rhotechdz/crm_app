import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/catalog/presentation/providers/products_provider.dart';
import 'package:talabati/features/catalog/presentation/screens/add_edit_product_screen.dart';
import 'package:talabati/features/catalog/presentation/screens/product_detail_screen.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'DA');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) =>
                  ref.read(searchProductQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search by product name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.imageUrl != null
                        ? Image.file(
                            File(product.imageUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Colors.grey),
                          )
                        : const Icon(Icons.shopping_bag, color: Colors.grey),
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(currencyFormat.format(product.sellingPrice)),
                          const SizedBox(width: 8),
                          Text(
                            'Cost: ${currencyFormat.format(product.costPrice)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (product.stockQuantity != null)
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stockQuantity! <= 5
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  onLongPress: () async {
                    final isInOrders = await ref
                        .read(productsProvider.notifier)
                        .isProductInOrders(product.id);

                    if (!context.mounted) return;

                    if (isInOrders) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'This product is used in existing orders and cannot be deleted.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Product'),
                        content: Text(
                            'Are you sure you want to delete ${product.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(productsProvider.notifier)
                                  .deleteProduct(product.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
