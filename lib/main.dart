import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/cosmos_theme.dart';

void main() => runApp(const CosmosInsightApp());

class CosmosInsightApp extends StatelessWidget {
  const CosmosInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmos Insight',
      debugShowCheckedModeBanner: false,
      theme: CosmosTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
