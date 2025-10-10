import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/controllers/network_controller.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: controller.animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: controller.fadeAnimation,
              child: ScaleTransition(
                scale: controller.scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        size: 60,
                        color: Color(0xFF6364FF),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App name
                    const Text(
                      '家庭照片站',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const Text(
                      'Family Photo Station',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Loading indicator
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Loading text (show detailed initialization info based on auth state)
                    GetBuilder<AuthController>(
                      builder: (authController) {
                        return Text(
                          controller.getLoadingText(authController.status),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Network status hint (show if there are errors)
                    GetBuilder<NetworkController>(
                      builder: (networkController) {
                        if (networkController.isConnected ||
                            networkController.errorMessage.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          networkController.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
