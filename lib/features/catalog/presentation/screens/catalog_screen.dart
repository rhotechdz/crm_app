import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/talabati_search_bar.dart';
import 'package:talabati/widgets/talabati_filter_chips.dart';
import 'package:talabati/features/catalog/presentation/providers/products_provider.dart';
import 'package:talabati/features/catalog/data/models/product.dart';
import 'package:talabati/features/catalog/presentation/screens/add_edit_product_screen.dart';

extension ProductExtension on Product {
  // Mapping missing/different fields to prompt names for compatibility
  String? get category => null; // Not currently in the model
  String get sku => id.substring(0, 8).toUpperCase(); 
  int get stock => stockQuantity ?? 0;
  String? get imagePath => imageUrl;
}

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _selectedCategory = 'All Products';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    
    // Category chips logic
    final categories = [
      'All Products',
      'In Stock',
      'Out of Stock',
      ...products
          .map((p) => p.category)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort()
    ];

    // Filtered list logic
    final filteredList = products.where((p) {
      // Category / Stock filter
      if (_selectedCategory == 'In Stock') {
        if (p.stock <= 0) return false;
      } else if (_selectedCategory == 'Out of Stock') {
        if (p.stock > 0) return false;
      } else if (_selectedCategory != 'All Products' && p.category != _selectedCategory) {
        return false;
      }
      
      // Search filter (name or sku)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesSku = p.sku.toLowerCase().contains(query);
        if (!matchesName && !matchesSku) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: const TalabatiAppBar(title: 'Talabati'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: TalabatiSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catalog',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${products.length} Active Products',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TalabatiSpacing.lg),
                TalabatiSearchBar(
                  hintText: 'Search products by name or SKU...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: TalabatiSpacing.md),
                TalabatiFilterChips(
                  options: categories,
                  selectedIndex: categories.indexOf(_selectedCategory),
                  onSelected: (index) {
                    setState(() => _selectedCategory = categories[index]);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: TalabatiColors.surface,
                            borderRadius: BorderRadius.circular(TalabatiRadius.lg),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 36,
                            color: TalabatiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: TalabatiSpacing.lg),
                        Text(
                          products.isEmpty ? "Your catalog is empty" : "No results found",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: TalabatiSpacing.sm),
                        Text(
                          products.isEmpty
                              ? "Add products to start\ncreating orders."
                              : "Try a different search term.",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.lg),
                    itemBuilder: (context, index) {
                      return _ProductCard(product: filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stock Status determination
    final StockStatus stockStatus;
    if (product.stock <= 0) {
      stockStatus = StockStatus.outOfStock;
    } else if (product.stock <= 10) {
      stockStatus = StockStatus.lowStock;
    } else {
      stockStatus = StockStatus.inStock;
    }

    final formattedPrice = '${NumberFormat('#,###').format(product.sellingPrice)} DA';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(TalabatiRadius.lg)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: TalabatiColors.badgeNeutralBg,
                  child: product.imagePath != null && File(product.imagePath!).existsSync()
                      ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported_outlined,
                          color: TalabatiColors.textSecondary, size: 48),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockStatus.backgroundColor,
                    borderRadius: TalabatiRadius.badgeRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(stockStatus.icon, size: 14, color: stockStatus.textColor),
                      const SizedBox(width: 4),
                      Text(
                        stockStatus.label,
                        style: TextStyle(
                          color: stockStatus.textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: TalabatiSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      formattedPrice,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TalabatiColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TalabatiSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 14, color: TalabatiColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${product.stock} in stock',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TalabatiColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TalabatiSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditProductScreen(product: product),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Edit Details'),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: Text('Are you sure you want to delete ${product.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            ref.read(productsProvider.notifier).deleteProduct(product.id);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
