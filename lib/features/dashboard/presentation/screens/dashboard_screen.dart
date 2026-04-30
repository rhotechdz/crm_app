import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToOrders;

  const DashboardScreen({super.key, required this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stat Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(title: 'Today', value: '12', onTap: onNavigateToOrders),
                _StatCard(title: 'Pending', value: '5', onTap: onNavigateToOrders),
                _StatCard(title: 'Courier', value: '3', onTap: onNavigateToOrders),
                _StatCard(title: 'Collection', value: '8', onTap: onNavigateToOrders),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: onNavigateToOrders, child: const Text('See all →')),
              ],
            ),
            // Placeholder list
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _StatCard({required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
