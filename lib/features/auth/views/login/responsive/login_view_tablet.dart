// lib/features/auth/views/login/responsive/login_view_tablet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_assets.dart';
import '../../../../../routes/app_routes.dart';
import '../components/login_form.dart';

class LoginViewTablet extends GetView<AuthController> {
  const LoginViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image on the right side (smaller than desktop)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: screenWidth * 0.4,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.loginBackground),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Container(
              width: screenWidth * 0.7,
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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

                    const SizedBox(height: 32),

                    // Logo
                    Center(
                      child: Image.asset(
                        AppAssets.ccLogoFullColour,
                        height: 70,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Welcome Back
                    Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
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
            ),
          ),

          // Decorative doodles
          // Pink dot
          Positioned(
            left: 30,
            top: screenHeight * 0.2,
            child: Image.asset(
              AppAssets.pinkDot,
              width: 20,
              height: 20,
            ),
          ),

          // Yellow dot
          Positioned(
            left: screenWidth * 0.55,
            bottom: screenHeight * 0.15,
            child: Image.asset(
              AppAssets.yellowDot,
              width: 28,
              height: 28,
            ),
          ),

          // Pink squiggle lines (straddling the form and background)
          Positioned(
            left: screenWidth * 0.5,
            top: screenHeight * 0.3,
            child: Image.asset(
              AppAssets.doodlePinkSquiggleLines,
              width: 100,
              height: 50,
            ),
          ),

          // Yellow half circle
          Positioned(
            left: 20,
            bottom: screenHeight * 0.25,
            child: Image.asset(
              AppAssets.doodleYellowHalfCircle,
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}