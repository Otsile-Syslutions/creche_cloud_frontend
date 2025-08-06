// lib/features/auth/views/sign_up/responsive/sign_up_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_assets.dart';

class SignUpViewDesktop extends GetView<AuthController> {
  const SignUpViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate responsive sizes
        final minScreenSize = screenWidth < screenHeight ? screenWidth : screenHeight;
        final scaleFactor = minScreenSize / 1000; // Base scale factor

        // Responsive sizes
        final logoHeight = (270 * scaleFactor).clamp(144.0, 288.0);
        final titleFontSize = (36 * scaleFactor).clamp(28.0, 48.0);
        final subtitleFontSize = (18 * scaleFactor).clamp(16.0, 24.0);
        final buttonFontSize = (16 * scaleFactor).clamp(14.0, 20.0);
        final linkFontSize = (14 * scaleFactor).clamp(12.0, 18.0);
        final termsFontSize = (12 * scaleFactor).clamp(10.0, 16.0);

        // Responsive padding
        final horizontalPadding = (60 * scaleFactor).clamp(40.0, 100.0);
        final verticalSpacing = (20 * scaleFactor).clamp(15.0, 30.0);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Main content row
              Row(
                children: [
                  // Left Side - Background Image (45%)
                  Expanded(
                    flex: 9,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.signupBackground),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Right Side - White Background with Content (55%)
                  Expanded(
                    flex: 11,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top section with login link
                            Padding(
                              padding: EdgeInsets.only(top: verticalSpacing),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: linkFontSize,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8 * scaleFactor),
                                  TextButton(
                                    onPressed: () => Get.toNamed(AppRoutes.login),
                                    child: Text(
                                      "Login!",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: linkFontSize,
                                        color: AppColors.loginButton,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Logo
                            Center(
                              child: Image.asset(
                                AppAssets.ccLogoFullColour,
                                height: logoHeight,
                              ),
                            ),

                            SizedBox(height: verticalSpacing * 0.8),

                            // Main Title
                            Text(
                              'Get Started With Creche Cloud',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: verticalSpacing),

                            // Divider line
                            Container(
                              width: screenWidth * 0.3,
                              height: 1,
                              color: Colors.grey.shade300,
                            ),

                            SizedBox(height: verticalSpacing),

                            // Subtitle
                            Text(
                              'Let\'s get you going! Tell us about yourself.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: subtitleFontSize,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: verticalSpacing * 2),

                            // Role Selection Buttons
                            Column(
                              children: [
                                _buildRoleButton(
                                  context,
                                  'I\'m a ECD owner or director',
                                      () => _handleRoleSelection('owner'),
                                  buttonFontSize,
                                  scaleFactor,
                                ),
                                SizedBox(height: verticalSpacing * 0.8),
                                _buildRoleButton(
                                  context,
                                  'I\'m a staff member',
                                      () => _handleRoleSelection('staff'),
                                  buttonFontSize,
                                  scaleFactor,
                                ),
                                SizedBox(height: verticalSpacing * 0.8),
                                _buildRoleButton(
                                  context,
                                  'I\'m a parent or guardian',
                                      () => _handleRoleSelection('parent'),
                                  buttonFontSize,
                                  scaleFactor,
                                ),
                              ],
                            ),

                            SizedBox(height: verticalSpacing * 1.5),

                            // Join using code section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Is your child's school on Creche Cloud?",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: linkFontSize,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 8 * scaleFactor),
                                GestureDetector(
                                  onTap: () => _handleJoinWithCode(),
                                  child: Text(
                                    "Join using your code",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: linkFontSize,
                                      color: AppColors.loginButton,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Terms of Use
                            Padding(
                              padding: EdgeInsets.only(bottom: verticalSpacing),
                              child: Text(
                                'By continuing you indicate that you have read and agree to the Terms of Use',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: termsFontSize,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Powder blue doodle positioned at the junction (overlapping both sides)
              Positioned(
                left: screenWidth * 0.28,
                top: -((580 * scaleFactor).clamp(360.0, 720.0) * 0.25),
                child: Image.asset(
                  AppAssets.doodlePowderBlue,
                  width: (1200 * scaleFactor).clamp(360.0, 720.0),
                  height: (1200 * scaleFactor).clamp(360.0, 720.0),
                ),
              ),

              // Pink squiggle lines doodle positioned to the right of divider line
              Positioned(
                right: -(200 * scaleFactor), // Bleed off the right edge - half the doodle shows
                top: (screenHeight * 0.02 + logoHeight + (verticalSpacing * 0.8) + titleFontSize + (verticalSpacing * 1.5)) * 0.7,
                child: Image.asset(
                  AppAssets.doodlePinkSquiggleLines,
                  width: (400 * scaleFactor).clamp(200.0, 600.0),
                  height: (300 * scaleFactor).clamp(150.0, 450.0),
                ),
              ),

              // Yellow dot doodle in bottom right of plain background
              Positioned(
                right: (80 * scaleFactor).clamp(60.0, 120.0),
                bottom: (120 * scaleFactor).clamp(80.0, 180.0),
                child: Image.asset(
                  AppAssets.yellowDot,
                  width: (80 * scaleFactor).clamp(40.0, 120.0),
                  height: (80 * scaleFactor).clamp(40.0, 120.0),
                ),
              ),

              // For Parents badge in the left middle of signup background
              Positioned(
                left: screenWidth * 0.06,
                top: screenHeight * 0.32,
                child: Container(
                  height: (60 * scaleFactor).clamp(48.0, 72.0),
                  padding: EdgeInsets.only(
                    left: (9.6 * scaleFactor).clamp(7.2, 14.4),
                    right: (56.0 * scaleFactor).clamp(42.0, 70.0),
                    top: (4.8 * scaleFactor).clamp(3.6, 7.2),
                    bottom: (4.8 * scaleFactor).clamp(3.6, 7.2),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBB3AE3), // Rectangle hex color
                    borderRadius: BorderRadius.circular((30 * scaleFactor).clamp(24.0, 36.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle with lightning icon
                      Container(
                        width: (50.4 * scaleFactor).clamp(38.4, 62.4),
                        height: (50.4 * scaleFactor).clamp(38.4, 62.4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF702388), // Circle hex color
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flash_on,
                          color: const Color(0xFF000000), // Black lightning icon
                          size: (28.8 * scaleFactor).clamp(21.6, 36.0),
                        ),
                      ),
                      SizedBox(width: (14.4 * scaleFactor).clamp(10.8, 18.0)),
                      // Text
                      Text(
                        'For Parents',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: (15.0 * scaleFactor).clamp(12.5, 19.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Teachers badge positioned above the purple circle dot doodle -
              Positioned(
                left: screenWidth * 0.37, // Centered above the purple circle dot doodle
                bottom: (232 * scaleFactor).clamp(168.0, 336.0),
                child: Container(
                  height: (65 * scaleFactor).clamp(52.0, 78.0),
                  padding: EdgeInsets.symmetric(
                    horizontal: (10.4 * scaleFactor).clamp(7.8, 15.6),
                    vertical: (5.2 * scaleFactor).clamp(3.9, 7.8),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D70F1),
                    borderRadius: BorderRadius.circular((32.5 * scaleFactor).clamp(26.0, 39.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle with lightning icon
                      Container(
                        width: (54.6 * scaleFactor).clamp(41.6, 67.6),
                        height: (54.6 * scaleFactor).clamp(41.6, 67.6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFA7A9F7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: (31.2 * scaleFactor).clamp(23.4, 39.0),
                        ),
                      ),
                      SizedBox(width: (15.6 * scaleFactor).clamp(10.4, 20.8)),
                      // Text
                      Text(
                        'For Teachers',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: (18.2 * scaleFactor).clamp(15.6, 23.4),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: (10.4 * scaleFactor).clamp(7.8, 15.6)),
                    ],
                  ),
                ),
              ),

              // Purple circle dot doodle at the bottom junction between bg and plain bg
              Positioned(
                left: screenWidth * 0.41, // At the junction between left and right sections
                bottom: (20 * scaleFactor).clamp(15.0, 30.0),
                child: Transform.rotate(
                  angle: 3.14159, // 180 degrees rotation
                  child: Image.asset(
                    AppAssets.doodlePurpleCircleDot,
                    width: (250 * scaleFactor).clamp(60.0, 180.0),
                    height: (250 * scaleFactor).clamp(60.0, 180.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleButton(
      BuildContext context,
      String text,
      VoidCallback onPressed,
      double fontSize,
      double scaleFactor,
      ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35, // 35% of screen width
      height: (55 * scaleFactor).clamp(45.0, 70.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleRoleSelection(String role) {
    // Handle role selection - navigate to appropriate signup form
    switch (role) {
      case 'owner':
      // Navigate to ECD owner signup
        Get.toNamed('${AppRoutes.signup}/owner');
        break;
      case 'staff':
      // Navigate to staff member signup
        Get.toNamed('${AppRoutes.signup}/staff');
        break;
      case 'parent':
      // Navigate to parent signup
        Get.toNamed('${AppRoutes.signup}/parent');
        break;
    }
  }

  void _handleJoinWithCode() {
    // Handle join with code - show dialog or navigate to code entry
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Join with School Code',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the code provided by your child\'s school to join their Creche Cloud community.',
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter school code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle code validation and joining
              Get.back();
              // Navigate to parent signup with code
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginButton,
            ),
            child: const Text(
              'Join',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}