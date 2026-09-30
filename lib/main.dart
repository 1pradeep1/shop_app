import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    // One provider at the top so every screen can read the same product state.
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const ZenmartApp(),
    ),
  );
}

class ZenmartApp extends StatelessWidget {
  const ZenmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenmart',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const LoginScreen(),
    );
  }
}
