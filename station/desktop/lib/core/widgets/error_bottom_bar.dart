import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/controllers/network_controller.dart';

class ErrorBottomBar extends StatelessWidget {
  const ErrorBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NetworkController>(
      builder: (controller) {
        final hasError = controller.errorMessage.isNotEmpty;
        if (!hasError) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onError,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.errorMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => controller.checkConnection(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('重试'),
              ),
              IconButton(
                onPressed: () => controller.resetConnectionStatus(),
                icon: const Icon(Icons.close, size: 18),
                color: Theme.of(context).colorScheme.onError.withValues(alpha: 0.8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }
}
