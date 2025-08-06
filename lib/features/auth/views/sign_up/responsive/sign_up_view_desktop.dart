// lib/features/auth/views/sign_up/responsive/sign_up_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../../routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_assets.dart';
import '../components/sign_up_role_buttons.dart';

class SignUpViewDesktop extends StatefulWidget {
  const SignUpViewDesktop({super.key});

  @override
  State<SignUpViewDesktop> createState() => _SignUpViewDesktopState();
}

class _SignUpViewDesktopState extends State<SignUpViewDesktop>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _purpleDotController;
  late AnimationController _yellowDotController;
  late AnimationController _pinkSquiggleController;
  late AnimationController _teddyController;

  // Animations
  late Animation<double> _purpleDotSwing;
  late Animation<Offset> _yellowDotCircle;
  late Animation<Offset> _pinkSquiggleWiggle;
  late Animation<double> _teddyScale;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _purpleDotController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _yellowDotController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _pinkSquiggleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _teddyController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize animations
    _purpleDotSwing = Tween<double>(
      begin: -0.15, // Swing angle in radians (~8.5 degrees)
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _purpleDotController,
      curve: Curves.easeInOut,
    ));

    _yellowDotCircle = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_yellowDotController);

    _pinkSquiggleWiggle = Tween<Offset>(
      begin: const Offset(-2, -2),
      end: const Offset(2, 2),
    ).animate(CurvedAnimation(
      parent: _pinkSquiggleController,
      curve: Curves.easeInOut,
    ));

    _teddyScale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _teddyController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _purpleDotController.repeat(reverse: true);
    _yellowDotController.repeat();
    _pinkSquiggleController.repeat(reverse: true);
    _teddyController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _purpleDotController.dispose();
    _yellowDotController.dispose();
    _pinkSquiggleController.dispose();
    _teddyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate responsive sizes - matching login view approach
        final minScreenSize = screenWidth < screenHeight ? screenWidth : screenHeight;
        final scaleFactor = minScreenSize / 1000; // Base scale factor

        // Responsive sizes with consistent clamping
        final logoHeight = (270 * scaleFactor).clamp(144.0, 288.0);
        final titleFontSize = (36 * scaleFactor).clamp(28.0, 48.0);
        final subtitleFontSize = (18 * scaleFactor).clamp(16.0, 24.0);
        final buttonFontSize = (16 * scaleFactor).clamp(14.0, 20.0);
        final linkFontSize = (14 * scaleFactor).clamp(12.0, 18.0);
        final termsFontSize = (12 * scaleFactor).clamp(10.0, 16.0);

        // Responsive padding - consistent with login view
        final horizontalPadding = (80 * scaleFactor).clamp(40.0, 120.0);
        final verticalSpacing = (20 * scaleFactor).clamp(15.0, 30.0);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Main content row - matching login view flex ratios for consistency
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
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight, // Ensure full height coverage when content is short
                          ),
                          child: IntrinsicHeight(
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

                                  SizedBox(height: verticalSpacing),

                                  // Divider line - responsive width
                                  Container(
                                    width: screenWidth * 0.25, // Percentage-based width
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),

                                  SizedBox(height: verticalSpacing * 2),

                                  // Role Selection Buttons
                                  SignUpRoleButtons(
                                    buttonFontSize: buttonFontSize,
                                    scaleFactor: scaleFactor,
                                    verticalSpacing: verticalSpacing,
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

                                  // Flexible spacer that grows to push Terms to bottom
                                  const Expanded(child: SizedBox()),

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
                      ),
                    ),
                  ),
                ],
              ),

              // Powder blue doodle positioned at the junction (9:11 ratio junction at 45%)
              Positioned(
                left: screenWidth * 0.45 - (screenWidth * 0.15), // Center on junction, offset left
                top: -(screenHeight * 0.15), // Percentage-based top positioning
                child: IgnorePointer(
                  child: Image.asset(
                    AppAssets.doodlePowderBlue,
                    width: (screenWidth * 0.3).clamp(360.0, 720.0), // Percentage-based sizing
                    height: (screenWidth * 0.3).clamp(360.0, 720.0),
                  ),
                ),
              ),

              // Pink squiggle lines doodle - positioned relative to screen
              Positioned(
                right: -(screenWidth * 0.08), // Percentage-based bleed
                top: screenHeight * 0.3, // Percentage-based positioning
                child: AnimatedBuilder(
                  animation: _pinkSquiggleWiggle,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _pinkSquiggleWiggle.value,
                      child: Image.asset(
                        AppAssets.doodlePinkSquiggleLines,
                        width: (screenWidth * 0.2).clamp(200.0, 600.0), // Percentage-based sizing
                        height: (screenWidth * 0.15).clamp(150.0, 450.0),
                      ),
                    );
                  },
                ),
              ),

              // Yellow dot doodle in bottom right - percentage positioning
              Positioned(
                right: screenWidth * 0.05, // 5% from right edge
                bottom: screenHeight * 0.12, // 12% from bottom
                child: AnimatedBuilder(
                  animation: _yellowDotController,
                  builder: (context, child) {
                    // Create circular motion
                    final circleRadius = 8.0 * scaleFactor;
                    final x = math.cos(_yellowDotController.value * 2 * math.pi) * circleRadius;
                    final y = math.sin(_yellowDotController.value * 2 * math.pi) * circleRadius;

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Image.asset(
                        AppAssets.yellowDot,
                        width: (screenWidth * 0.04).clamp(40.0, 120.0), // Percentage-based sizing
                        height: (screenWidth * 0.04).clamp(40.0, 120.0),
                      ),
                    );
                  },
                ),
              ),

              // For Parents badge - positioned relative to left side
              Positioned(
                left: screenWidth * 0.07, // 7% from left edge (moved right by 3%)
                top: screenHeight * 0.32, // 32% from top
                child: Container(
                  height: (60 * scaleFactor).clamp(48.0, 72.0),
                  padding: EdgeInsets.only(
                    left: (9.6 * scaleFactor).clamp(7.2, 14.4),
                    right: (56.0 * scaleFactor).clamp(42.0, 70.0),
                    top: (4.8 * scaleFactor).clamp(3.6, 7.2),
                    bottom: (4.8 * scaleFactor).clamp(3.6, 7.2),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBB3AE3),
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
                          color: Color(0xFF702388),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flash_on,
                          color: const Color(0xFF000000),
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

              // Frosted grey opaque rectangle below "For Parents" badge
              Positioned(
                left: screenWidth * 0.07, // Same as badge (moved right by 3%)
                top: screenHeight * 0.32 + (60 * scaleFactor).clamp(48.0, 72.0) + (16 * scaleFactor).clamp(12.0, 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular((12 * scaleFactor).clamp(9.0, 15.0)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: (246 * scaleFactor).clamp(184.5, 307.5),
                      height: (158 * scaleFactor).clamp(118.5, 197.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF808080).withOpacity(0.4),
                        borderRadius: BorderRadius.circular((12 * scaleFactor).clamp(9.0, 15.0)),
                      ),
                      child: Stack(
                        children: [
                          // Purple square centered behind teddy bear
                          Positioned(
                            top: (8 * scaleFactor).clamp(6.0, 12.0) + (7 * scaleFactor).clamp(5.25, 8.75),
                            left: (8 * scaleFactor).clamp(6.0, 12.0) + (7 * scaleFactor).clamp(5.25, 8.75),
                            child: Container(
                              width: (42 * scaleFactor).clamp(31.5, 52.5),
                              height: (42 * scaleFactor).clamp(31.5, 52.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF875DEC),
                                borderRadius: BorderRadius.circular((8 * scaleFactor).clamp(6.0, 10.0)),
                              ),
                            ),
                          ),

                          // Teddy bear image with breathing animation
                          Positioned(
                            top: (8 * scaleFactor).clamp(6.0, 12.0),
                            left: (8 * scaleFactor).clamp(6.0, 12.0),
                            child: AnimatedBuilder(
                              animation: _teddyScale,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _teddyScale.value,
                                  child: Image.asset(
                                    'assets/doodles/doodle_teddy.png',
                                    width: (56 * scaleFactor).clamp(42.0, 70.0),
                                    height: (56 * scaleFactor).clamp(42.0, 70.0),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Text below teddy doodle
                          Positioned(
                            top: (8 * scaleFactor).clamp(6.0, 12.0) + (56 * scaleFactor).clamp(42.0, 70.0) + (8 * scaleFactor).clamp(6.0, 12.0),
                            left: (12 * scaleFactor).clamp(9.0, 15.0),
                            right: (12 * scaleFactor).clamp(9.0, 15.0),
                            bottom: (12 * scaleFactor).clamp(9.0, 15.0),
                            child: Text(
                              "Every Step Of Your Child's Creche Journey!",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: (16 * scaleFactor).clamp(12.0, 20.0),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Teachers badge - positioned at junction point (9:11 ratio = 45% mark)
              Positioned(
                left: screenWidth * 0.40, // Near junction at 45% mark
                bottom: screenHeight * 0.25, // Percentage from bottom
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

              // Purple circle dot doodle at junction (9:11 ratio junction) with swing animation
              Positioned(
                left: screenWidth * 0.45 - (84 * scaleFactor), // Adjusted for new larger size (168/2 = 84)
                bottom: screenHeight * 0.04, // Moved down from 8% to 4% (10% down relative movement)
                child: AnimatedBuilder(
                  animation: _purpleDotSwing,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: 3.14159 + _purpleDotSwing.value, // 180 degrees rotation + swing
                      child: Image.asset(
                        AppAssets.doodlePurpleCircleDot,
                        width: (168 * scaleFactor).clamp(84.0, 252.0), // 40% bigger: 120 * 1.4 = 168
                        height: (168 * scaleFactor).clamp(84.0, 252.0), // 40% bigger: 120 * 1.4 = 168
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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