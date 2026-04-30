import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/talabati_search_bar.dart';
import 'package:talabati/widgets/talabati_filter_chips.dart';
import 'package:talabati/widgets/status_badge.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All Products', 'Electronics', 'Home', 'Fashion'];

  @override
  Widget build(BuildContext context) {
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
                  '48 Active Products',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TalabatiSpacing.lg),
                const TalabatiSearchBar(
                  hintText: 'Search products by name or SKU...',
                ),
                const SizedBox(height: TalabatiSpacing.md),
                TalabatiFilterChips(
                  options: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (index) => setState(() => _selectedFilterIndex = index),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.lg),
              itemBuilder: (context, index) {
                final isLowStock = index == 1;
                return _ProductCard(
                  name: index == 0 ? 'Wireless Earbuds' : (isLowStock ? 'Premium Watch' : 'Leather Wallet'),
                  price: index == 0 ? '4,500 DA' : (isLowStock ? '12,000 DA' : '3,200 DA'),
                  stockStatus: index == 0 ? StockStatus.inStock : (isLowStock ? StockStatus.lowStock : StockStatus.inStock),
                  stockQuantity: index == 0 ? 24 : (isLowStock ? 4 : 12),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_box_outlined),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final StockStatus stockStatus;
  final int stockQuantity;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.stockStatus,
    required this.stockQuantity,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Icons.image_outlined, size: 48, color: TalabatiColors.textSecondary),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: StatusBadge(
                  label: stockStatus.label,
                  backgroundColor: stockStatus.backgroundColor,
                  textColor: stockStatus.textColor,
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
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: TalabatiSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 14, color: TalabatiColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '$stockQuantity in stock',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: TalabatiSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Edit Details'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () {},
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
