import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mybudget/core/theme_provider.dart';
import 'package:mybudget/screens/welcome/welcome_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyBudgetApp(),
    ),
  );
}

class MyBudgetApp extends StatelessWidget {
  const MyBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).themeData;
    return MaterialApp(
      title: 'MYBudget',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const WelcomePage(),
    );
  }
}
