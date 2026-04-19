import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final isSel = c == selected;
          return GestureDetector(
            onTap: () => onSelected(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? AppTheme.primaryBlue : const Color(0xFFE5EAF2)),
              ),
              alignment: Alignment.center,
              child: Text(
                c,
                style: TextStyle(
                  color: isSel ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
