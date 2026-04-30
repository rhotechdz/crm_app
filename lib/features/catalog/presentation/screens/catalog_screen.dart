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
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 140),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(context, ref, product);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          height: 44,
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, 
                                size: 18, 
                                color: TalabatiColors.danger),
                              const SizedBox(width: 12),
                              Text(
                                'Delete Product', 
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: TalabatiColors.danger,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TalabatiRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: TalabatiColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: TalabatiColors.danger,
                size: 32,
              ),
            ),
            const SizedBox(height: TalabatiSpacing.lg),
            Text(
              'Delete Product?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TalabatiSpacing.sm),
            Text(
              'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TalabatiColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TalabatiSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: TalabatiColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TalabatiRadius.md),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: TalabatiSpacing.base),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(productsProvider.notifier).deleteProduct(product.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TalabatiColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TalabatiRadius.md),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
