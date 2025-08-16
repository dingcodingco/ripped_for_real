import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  
  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final Map<String, IconData> categoryIcons = const {
    'mindset': Icons.psychology,
    'money': Icons.attach_money,
    'strength': Icons.fitness_center,
    'discipline': Icons.military_tech,
    'success': Icons.emoji_events,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(context, null, 'ALL', Icons.apps),
          ...categoryIcons.entries.map((entry) => 
            _buildCategoryChip(
              context,
              entry.key,
              entry.key.toUpperCase(),
              entry.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String? category,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (_) => onCategorySelected(category),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        selectedColor: Colors.white,
        checkmarkColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.white : Colors.grey[700]!,
            width: 1,
          ),
        ),
      ),
    );
  }
}