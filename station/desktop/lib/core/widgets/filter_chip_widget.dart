import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = selectedColor ?? theme.primaryColor;
    final backgroundColor = isSelected 
        ? primaryColor.withValues(alpha: 0.1)
        : unselectedColor ?? theme.colorScheme.surface;
    final borderColor = isSelected 
        ? primaryColor
        : theme.colorScheme.outline.withValues(alpha: 0.3);
    final textColor = isSelected 
        ? primaryColor
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: textColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipGroup extends StatelessWidget {
  final List<FilterChipData> chips;
  final String? selectedValue;
  final Function(String) onSelectionChanged;
  final bool allowMultipleSelection;
  final Set<String>? selectedValues;

  const FilterChipGroup({
    Key? key,
    required this.chips,
    required this.onSelectionChanged,
    this.selectedValue,
    this.allowMultipleSelection = false,
    this.selectedValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((chip) {
        final isSelected = allowMultipleSelection
            ? selectedValues?.contains(chip.value) ?? false
            : selectedValue == chip.value;

        return FilterChipWidget(
          label: chip.label,
          icon: chip.icon,
          isSelected: isSelected,
          onTap: () => onSelectionChanged(chip.value),
          selectedColor: chip.selectedColor,
          unselectedColor: chip.unselectedColor,
        );
      }).toList(),
    );
  }
}

class FilterChipData {
  final String label;
  final String value;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FilterChipData({
    required this.label,
    required this.value,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });
}