// lib/features/auth/views/reset_password/responsive/reset_password_view_tablet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';

class ResetPasswordViewTablet extends GetView<AuthController> {
  const ResetPasswordViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 50,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Enter your new password below.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: controller.resetPasswordFormKey,
                    child: Column(
                      children: [
                        // New Password Field
                        TextFormField(
                          controller: controller.newPasswordController,
                          obscureText: true,
                          validator: controller.validatePassword,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Confirm Password Field
                        TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText: true,
                          validator: controller.validateConfirmPassword,
                          decoration: const InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Reset Password Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.resetPassword,
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Reset Password',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )),

                        const SizedBox(height: 24),

                        // Back to Login
                        TextButton(
                          onPressed: () => Get.offAllNamed(AppRoutes.login),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}