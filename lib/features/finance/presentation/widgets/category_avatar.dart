import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

/// Ícones disponíveis para categorias. Mapa constante para que o
/// tree-shaking de ícones continue funcionando no build de release.
const categoryIcons = <String, IconData>{
  'restaurant': Icons.restaurant,
  'home': Icons.home_outlined,
  'car': Icons.directions_car_outlined,
  'health': Icons.local_hospital_outlined,
  'movie': Icons.movie_outlined,
  'school': Icons.school_outlined,
  'shopping': Icons.shopping_bag_outlined,
  'receipt': Icons.receipt_long_outlined,
  'pets': Icons.pets_outlined,
  'travel': Icons.flight_outlined,
  'gym': Icons.fitness_center,
  'phone': Icons.smartphone_outlined,
  'gift': Icons.card_giftcard,
  'coffee': Icons.local_cafe_outlined,
  'market': Icons.local_grocery_store_outlined,
  'work': Icons.work_outline,
  'laptop': Icons.laptop_mac,
  'trending': Icons.trending_up,
  'savings': Icons.savings_outlined,
  'more': Icons.more_horiz,
};

const categoryColors = <int>[
  0xFFEF6C00,
  0xFF1565C0,
  0xFF6A1B9A,
  0xFFD81B60,
  0xFF00838F,
  0xFF5D4037,
  0xFFAD1457,
  0xFF455A64,
  0xFF2E7D32,
  0xFF00897B,
  0xFF558B2F,
  0xFFF9A825,
  0xFF283593,
  0xFF757575,
];

IconData iconFor(String key) => categoryIcons[key] ?? Icons.more_horiz;

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.radius = 20});

  /// Pode ser nulo quando a categoria foi removida.
  final FinanceCategory? category;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Color(category?.colorValue ?? 0xFF757575);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(
        iconFor(category?.iconKey ?? 'more'),
        color: color,
        size: radius,
      ),
    );
  }
}
