import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/catalog/data/models/product.dart';
import 'package:talabati/features/catalog/data/models/product_variant.dart';
import 'package:talabati/features/catalog/presentation/providers/products_provider.dart';
import 'package:talabati/features/orders/data/models/order_item.dart';

class ProductPickerScreen extends ConsumerStatefulWidget {
  const ProductPickerScreen({super.key});

  @override
  ConsumerState<ProductPickerScreen> createState() =>
      _ProductPickerScreenState();
}

class _ProductPickerScreenState extends ConsumerState<ProductPickerScreen> {
  String _query = '';
  Product? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'DA');
    final query = _query.toLowerCase().trim();
    final filteredProducts = products.where((product) {
      return query.isEmpty || product.name.toLowerCase().contains(query);
    }).toList();

    if (_selectedProduct != null) {
      return _buildVariantStep(context, _selectedProduct!, currencyFormat);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pick Product')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search by product name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ListTile(
                        leading: _ProductThumbnail(product: product),
                        title: Text(product.name),
                        subtitle: Text(
                          currencyFormat.format(product.sellingPrice),
                        ),
                        trailing: product.variants.isEmpty
                            ? const Icon(Icons.add_circle_outline)
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          if (product.variants.isEmpty) {
                            Navigator.pop(
                              context,
                              _itemFromProduct(product, null),
                            );
                          } else {
                            setState(() => _selectedProduct = product);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantStep(
    BuildContext context,
    Product product,
    NumberFormat currencyFormat,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Variant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedProduct = null),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: _ProductThumbnail(product: product),
            title: Text(product.name),
            subtitle: Text(
              'Base price: ${currencyFormat.format(product.sellingPrice)}',
            ),
          ),
          const Divider(),
          for (final variant in product.variants)
            ListTile(
              title: Text(variant.label),
              subtitle: Text(
                '+ ${currencyFormat.format(variant.additionalPrice)}',
              ),
              trailing: Text(
                currencyFormat.format(
                  product.sellingPrice + variant.additionalPrice,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () =>
                  Navigator.pop(context, _itemFromProduct(product, variant)),
            ),
        ],
      ),
    );
  }

  OrderItem _itemFromProduct(Product product, ProductVariant? variant) {
    return OrderItem(
      productId: product.id,
      productName: product.name,
      variantLabel: variant?.label,
      quantity: 1,
      unitPrice: product.sellingPrice + (variant?.additionalPrice ?? 0),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final Product product;

  const _ProductThumbnail({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
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
    );
  }
}
