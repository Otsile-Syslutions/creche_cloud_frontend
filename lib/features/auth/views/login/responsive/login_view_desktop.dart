// lib/features/auth/views/login/responsive/login_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_assets.dart';
import '../controllers/login_form_controller.dart';
import '../components/login_form.dart';
import '../components/promotional_slider.dart';

class LoginViewDesktop extends GetView<AuthController> {
  const LoginViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AnimatedLoginView();
  }
}

class _AnimatedLoginView extends StatefulWidget {
  const _AnimatedLoginView();

  @override
  State<_AnimatedLoginView> createState() => _AnimatedLoginViewState();
}

class _AnimatedLoginViewState extends State<_AnimatedLoginView>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _squiggleController;
  late AnimationController _yellowDotController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _squiggleAnimation;
  late Animation<double> _yellowDotAnimation;

  @override
  void initState() {
    super.initState();

// Floating animation for doodles
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

// Rotation animation for pink dot
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

// Pulse animation for yellow half circle
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

// Squiggle lines wave animation
    _squiggleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _squiggleAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _squiggleController,
      curve: Curves.easeInOut,
    ));

// Yellow dot oscillation animation
    _yellowDotController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _yellowDotAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _yellowDotController,
      curve: Curves.easeInOut,
    ));

// Start animations with safety checks
    if (mounted) {
      _floatingController.repeat(reverse: true);
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
      _squiggleController.repeat(reverse: true);
      _yellowDotController.repeat(reverse: true);
    }
  }

  @override
  void deactivate() {
// Stop animations when widget becomes inactive
    _floatingController.stop();
    _rotationController.stop();
    _pulseController.stop();
    _squiggleController.stop();
    _yellowDotController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
// Stop all animations before disposing
    _floatingController.stop();
    _rotationController.stop();
    _pulseController.stop();
    _squiggleController.stop();
    _yellowDotController.stop();

// Dispose all controllers
    _floatingController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _squiggleController.dispose();
    _yellowDotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

// Calculate responsive sizes and positions
        final minScreenSize = screenWidth < screenHeight ? screenWidth : screenHeight;
        final scaleFactor = minScreenSize / 1000; // Base scale factor

// Responsive decorative element sizes
        final pinkDotSize = (34 * scaleFactor).clamp(20.0, 50.0);
        final yellowDotSize = (32 * scaleFactor).clamp(18.0, 48.0);
        final yellowHalfCircleSize = (120 * scaleFactor).clamp(60.0, 180.0);
        final squiggleSize = (120 * scaleFactor).clamp(80.0, 160.0);

// Responsive logo size
        final logoHeight = (230 * scaleFactor).clamp(120.0, 300.0);

// Responsive padding
        final horizontalPadding = (80 * scaleFactor).clamp(40.0, 120.0);
        final topPadding = (40 * scaleFactor).clamp(20.0, 60.0);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () {
// Submit form when Enter is pressed globally
                try {
                  final loginFormController = Get.find<LoginFormController>();
                  loginFormController.submitForm();
                } catch (e) {
// Fallback to auth controller if form controller not available
                  final AuthController authController = Get.find<AuthController>();
                  if (!authController.isLoading.value) {
                    authController.login();
                  }
                }
              },
            },
            child: Focus(
              autofocus: true,
              child: Stack(
                children: [
// Main content row (60% white, 40% background image)
                  Row(
                    children: [
// Left Side - White Background with Form (60%)
                      Expanded(
                        flex: 6,
                        child: Container(
                          color: Colors.white,
                          child: Stack(
                            children: [
// Animated Pink dot bleeding off the left edge
                              AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  if (!mounted) return const SizedBox.shrink();
                                  return Positioned(
                                    left: -(pinkDotSize * 0.3), // Proportional bleeding
                                    top: screenHeight * 0.15 + _floatingAnimation.value,
                                    child: Image.asset(
                                      AppAssets.pinkDot,
                                      width: pinkDotSize,
                                      height: pinkDotSize,
                                    ),
                                  );
                                },
                              ),

// Animated Yellow half circle bleeding off the left edge
                              AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  if (!mounted) return const SizedBox.shrink();
                                  return AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      if (!mounted) return const SizedBox.shrink();
                                      return Positioned(
                                        left: -(yellowHalfCircleSize * 0.3),
                                        bottom: screenHeight * 0.2 - _floatingAnimation.value - (screenHeight * 0.1),
                                        child: Transform.scale(
                                          scale: _pulseAnimation.value,
                                          child: Image.asset(
                                            AppAssets.doodleYellowHalfCircle,
                                            width: yellowHalfCircleSize,
                                            height: yellowHalfCircleSize,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

// Main content with responsive layout
                              _buildMainContent(
                                screenWidth,
                                screenHeight,
                                horizontalPadding,
                                topPadding,
                                logoHeight,
                                scaleFactor,
                              ),

// Animated Yellow dot on the right edge (oscillating)
                              AnimatedBuilder(
                                animation: _yellowDotAnimation,
                                builder: (context, child) {
                                  if (!mounted) return const SizedBox.shrink();
                                  return Positioned(
                                    right: (screenWidth * 0.05) + _yellowDotAnimation.value,
                                    bottom: screenHeight * 0.15,
                                    child: Image.asset(
                                      AppAssets.yellowDot,
                                      width: yellowDotSize,
                                      height: yellowDotSize,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

// Right Side - Background Image (40%)
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AppAssets.loginBackground),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

// Promotional slider overlay - responsive positioning
                  Positioned(
                    right: screenWidth * 0.010, // 1.5% from right edge
                    bottom: screenHeight * 0.08,
                    width: screenWidth * 0.38, // 35% of screen width
                    height: screenHeight * 0.20, //
                    child: const PromotionalSlider(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

// Animated Pink squiggle lines overlay (straddling the division line)
                  AnimatedBuilder(
                    animation: _squiggleAnimation,
                    builder: (context, child) {
                      if (!mounted) return const SizedBox.shrink();
                      return Positioned(
                        left: screenWidth * 0.6 - (squiggleSize * 0.5), // Centered on division
                        top: screenHeight * 0.25 + _squiggleAnimation.value,
                        child: Image.asset(
                          AppAssets.doodlePinkSquiggleLines,
                          width: squiggleSize,
                          height: squiggleSize * 0.5, // Maintain aspect ratio
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
      double screenWidth,
      double screenHeight,
      double horizontalPadding,
      double topPadding,
      double logoHeight,
      double scaleFactor,
      ) {
// Responsive font sizes
    final signupFontSize = (14 * scaleFactor).clamp(12.0, 18.0);
    final titleFontSize = (32 * scaleFactor).clamp(24.0, 40.0);
    final subtitleFontSize = (16 * scaleFactor).clamp(14.0, 20.0);

// Calculate equal spacing - measure from after signup section to before final spacing
// We want the space above logo to equal the space below social buttons
    final equalSpacing = screenHeight * 0.04; // 4% of screen height for both

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Top section with sign up link
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: signupFontSize,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(width: 8 * scaleFactor),
                Builder(
                  builder: (context) {
// Get the login form controller for focus management
                    try {
                      final loginFormController = Get.find<LoginFormController>();
                      return FocusTraversalOrder(
                        order: const NumericFocusOrder(6),
                        child: Focus(
                          focusNode: loginFormController.signupLinkFocusNode,
                          child: _SignUpButton(
                            onPressed: () {
                              // Set navigation flag before navigating
                              loginFormController.setNavigatingToSignup();
                              Get.toNamed(AppRoutes.signup);
                            },
                            fontSize: signupFontSize,
                          ),
                        ),
                      );
                    } catch (e) {
// Fallback if controller not available
                      return _SignUpButton(
                        onPressed: () {
                          // Try to find controller and set navigation flag
                          try {
                            final loginFormController = Get.find<LoginFormController>();
                            loginFormController.setNavigatingToSignup();
                          } catch (e) {
                            // If controller not found, just navigate
                          }
                          Get.toNamed(AppRoutes.signup);
                        },
                        fontSize: signupFontSize,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

// Equal spacing above logo
          SizedBox(height: equalSpacing),

// Logo with responsive sizing
          Center(
            child: Image.asset(
              AppAssets.ccLogoFullColour,
              height: logoHeight,
            ),
          ),

          SizedBox(height: screenHeight * 0.02), // 2% of screen height

// Welcome Back - responsive
          Center(
            child: Text(
              'Welcome Back',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.006), // 0.6% of screen height

// Login into your account - responsive
          Center(
            child: Text(
              'Login into your account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: subtitleFontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.025), // 2.5% of screen height

// Login Form - this will handle its own responsive layout
          const Expanded(
            child: LoginForm(),
          ),

// Equal spacing below social buttons
          SizedBox(height: equalSpacing),
        ],
      ),
    );
  }
}

// Custom Sign Up Button with hover state - Updated to call navigation tracking
class _SignUpButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double fontSize;

  const _SignUpButton({
    required this.onPressed,
    required this.fontSize,
  });

  @override
  State<_SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<_SignUpButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: _isHovering
              ? AppColors.signupPink.withOpacity(0.8) // Slightly darker shade on hover
              : AppColors.signupPink,
          overlayColor: AppColors.signupPink.withOpacity(0.1), // Light pink overlay
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          "Sign up!",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: widget.fontSize,
            color: _isHovering
                ? AppColors.signupPink.withOpacity(0.8) // Darker shade on hover
                : AppColors.signupPink, // Original pink
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}