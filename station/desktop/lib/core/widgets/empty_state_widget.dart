import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyPhotosWidget extends StatelessWidget {
  final VoidCallback? onUploadPressed;

  const EmptyPhotosWidget({
    Key? key,
    this.onUploadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.photo_library_outlined,
      title: 'No photos found',
      subtitle: 'Upload some photos to get started',
      actionText: 'Upload Photos',
      onActionPressed: onUploadPressed,
    );
  }
}

class EmptyAlbumsWidget extends StatelessWidget {
  final VoidCallback? onCreatePressed;

  const EmptyAlbumsWidget({
    Key? key,
    this.onCreatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.photo_album_outlined,
      title: 'No albums found',
      subtitle: 'Create your first album to organize your photos',
      actionText: 'Create Album',
      onActionPressed: onCreatePressed,
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchWidget({
    Key? key,
    required this.searchQuery,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      subtitle: 'No items match your search for "$searchQuery"',
      actionText: 'Clear Search',
      onActionPressed: onClearSearch,
    );
  }
}

class EmptyUsersWidget extends StatelessWidget {
  final VoidCallback? onInvitePressed;

  const EmptyUsersWidget({
    Key? key,
    this.onInvitePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No users found',
      subtitle: 'Invite family members to join your photo station',
      actionText: 'Invite Users',
      onActionPressed: onInvitePressed,
    );
  }
}
