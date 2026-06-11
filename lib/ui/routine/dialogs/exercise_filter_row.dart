import 'package:flutter/material.dart';
import 'icon_mapper.dart';

class ExerciseFilterRow extends StatelessWidget {
  final List<String> items;
  final String? activeItem;
  final bool isEquipment;
  final Function(String?) onSelect;

  const ExerciseFilterRow({
    super.key,
    required this.items,
    required this.activeItem,
    required this.isEquipment,
    required this.onSelect,
  });

  String _capitalize(String s) => s.isEmpty ? s : "${s[0].toUpperCase()}${s.substring(1)}";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: items.map((item) {
          final isSelected = activeItem == item;
          final iconData = isEquipment ? IconMapper.getEquipmentIcon(item) : IconMapper.getMuscleIcon(item);
          final activeColor = isEquipment ? const Color(0xFFB0C4DE) : const Color(0xFFE1C19F);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(iconData, size: 16, color: isSelected ? const Color(0xFF131313) : const Color(0xFFCAC6BB)),
              label: Text(_capitalize(item)),
              selected: isSelected,
              onSelected: (selected) => onSelect(selected ? item : null),
              backgroundColor: const Color(0xFF1F1F1F),
              selectedColor: activeColor,
              labelStyle: TextStyle(color: isSelected ? const Color(0xFF131313) : const Color(0xFFCAC6BB), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}
