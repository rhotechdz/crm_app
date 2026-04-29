import 'package:flutter/material.dart';
import 'package:talabati/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:talabati/features/orders/presentation/screens/orders_screen.dart';
import 'package:talabati/features/clients/presentation/screens/clients_screen.dart';
import 'package:talabati/features/catalog/presentation/screens/catalog_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrdersScreen(),
    const ClientsScreen(),
    const CatalogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catalog'),
        ],
      ),
    );
  }
}
