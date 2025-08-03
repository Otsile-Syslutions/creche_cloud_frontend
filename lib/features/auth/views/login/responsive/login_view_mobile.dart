// lib/features/auth/views/login/responsive/login_view_mobile.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_assets.dart';
import '../../../../../routes/app_routes.dart';
import '../components/login_form.dart';

class LoginViewMobile extends GetView<AuthController> {
  const LoginViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.loginBackground),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),

            // Main scrollable content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Top section with background image space
                  SizedBox(height: screenHeight * 0.25),

                  // White container with form
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.signup),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Sign up!",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: AppColors.signupPink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Logo
                        Center(
                          child: Image.asset(
                            AppAssets.ccLogoFullColour,
                            height: 60,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Welcome Back
                        Center(
                          child: Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Login into your account
                        Center(
                          child: Text(
                            'Login into your account',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Form
                        const LoginForm(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Decorative doodles
            // Pink dot
            Positioned(
              left: 20,
              top: screenHeight * 0.4,
              child: Image.asset(
                AppAssets.pinkDot,
                width: 20,
                height: 20,
              ),
            ),

            // Yellow dot
            Positioned(
              right: 20,
              bottom: 120,
              child: Image.asset(
                AppAssets.yellowDot,
                width: 24,
                height: 24,
              ),
            ),

            // Pink squiggle lines
            Positioned(
              right: 40,
              top: screenHeight * 0.35,
              child: Image.asset(
                AppAssets.doodlePinkSquiggleLines,
                width: 80,
                height: 40,
              ),
            ),

            // Yellow half circle
            Positioned(
              left: 10,
              bottom: 200,
              child: Image.asset(
                AppAssets.doodleYellowHalfCircle,
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}