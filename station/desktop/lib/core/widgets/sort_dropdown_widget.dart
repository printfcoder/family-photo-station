import 'package:flutter/material.dart';

class SortDropdownWidget<T> extends StatelessWidget {
  final T selectedValue;
  final List<SortOption<T>> options;
  final Function(T) onChanged;
  final String label;
  final IconData? icon;

  const SortDropdownWidget({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.label = 'Sort by',
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          onChanged: (T? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
          ),
          dropdownColor: theme.colorScheme.surface,
          items: options.map<DropdownMenuItem<T>>((SortOption<T> option) {
            return DropdownMenuItem<T>(
              value: option.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(option.label),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SortOption<T> {
  final String label;
  final T value;
  final IconData? icon;

  const SortOption({
    required this.label,
    required this.value,
    this.icon,
  });
}

class SortBar extends StatelessWidget {
  final Widget sortWidget;
  final List<Widget>? additionalActions;
  final String? title;

  const SortBar({
    Key? key,
    required this.sortWidget,
    this.additionalActions,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
          ],
          sortWidget,
          if (additionalActions != null) ...[
            const SizedBox(width: 12),
            ...additionalActions!,
          ],
        ],
      ),
    );
  }
}
