import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/features/home/presentation/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talabati CRM',
      debugShowCheckedModeBanner: false,
      theme: TalabatiTheme.light,
      home: const MainScreen(),
    );
  }
}
