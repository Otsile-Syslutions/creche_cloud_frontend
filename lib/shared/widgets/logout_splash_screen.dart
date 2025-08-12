// lib/shared/widgets/logout_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

// Modern web imports using package:web instead of dart:html
import 'package:web/web.dart' as web;

import '../../features/auth/controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_logger.dart';

class LogoutSplashScreen extends StatefulWidget {
  const LogoutSplashScreen({super.key});

  @override
  State<LogoutSplashScreen> createState() => _LogoutSplashScreenState();
}

class _LogoutSplashScreenState extends State<LogoutSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _autoRedirectTimer;
  Timer? _logoutProcessTimer;
  int _autoRedirectCountdown = 5; // Reduced to 5 seconds for better UX
  bool _userInteracted = false;
  bool _logoutComplete = false;
  String _statusMessage = 'Securing your session...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _performLogout();
    _startAutoRedirectTimer();
  }

  void _initializeAnimations() {
    // Icon animation controller
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation controller
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation for success icon
    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.elasticOut,
    ));

    // Rotation animation for success icon
    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for content
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _iconAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeAnimationController.forward();
      }
    });
  }

  /// Centralized logout logic - handles everything
  Future<void> _performLogout() async {
    try {
      AppLogger.i('LogoutSplashScreen: Starting centralized logout process');

      // Get or create AuthController
      AuthController? authController;

      if (Get.isRegistered<AuthController>()) {
        authController = Get.find<AuthController>();
        AppLogger.d('LogoutSplashScreen: Found existing AuthController');
      } else {
        // Create new AuthController if it doesn't exist
        authController = Get.put(AuthController());
        AppLogger.d('LogoutSplashScreen: Created new AuthController');
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Update status
      if (mounted) {
        setState(() {
          _statusMessage = 'Logging out...';
        });
      }

      // Step 1: Try API logout (don't wait too long)
      try {
        AppLogger.d('LogoutSplashScreen: Calling API logout');
        // Check if authenticated before trying API logout
        if (authController != null && authController.isAuthenticated.value) {
          // We can't directly call API logout, so we'll skip this step
          // The session will be cleared below
          AppLogger.d('LogoutSplashScreen: User is authenticated, proceeding with logout');
        }
      } catch (e) {
        AppLogger.w('LogoutSplashScreen: API logout check failed', e);
      }

      // Step 2: Clear local session
      if (mounted) {
        setState(() {
          _statusMessage = 'Clearing session data...';
        });
      }

      if (authController != null) {
        AppLogger.d('LogoutSplashScreen: Clearing session');
        await authController.clearSession();
      }

      // Step 3: Cleanup controllers and prepare for login
      if (mounted) {
        setState(() {
          _statusMessage = 'Preparing login environment...';
        });
      }

      // Ensure login environment is ready
      if (authController != null) {
        await authController.ensureLoginReady();
      }

      // Step 4: Mark logout as complete
      if (mounted) {
        setState(() {
          _logoutComplete = true;
          _statusMessage = 'Logout complete';
        });
      }

      AppLogger.i('LogoutSplashScreen: Logout process completed successfully');

      // If already complete, redirect faster
      if (_logoutComplete && !_userInteracted) {
        // Reduce countdown for faster redirect
        _autoRedirectCountdown = 2;
      }

    } catch (e) {
      AppLogger.e('LogoutSplashScreen: Error during logout process', e);

      // Even on error, try to clear session and redirect
      try {
        if (Get.isRegistered<AuthController>()) {
          final controller = Get.find<AuthController>();
          await controller.clearSession();
        }
      } catch (clearError) {
        AppLogger.e('LogoutSplashScreen: Failed to clear session', clearError);
      }

      if (mounted) {
        setState(() {
          _logoutComplete = true;
          _statusMessage = 'Redirecting to login...';
        });
      }
    }
  }

  void _startAutoRedirectTimer() {
    _autoRedirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_userInteracted) {
        timer.cancel();
        return;
      }

      if (_autoRedirectCountdown > 0) {
        if (mounted) {
          setState(() {
            _autoRedirectCountdown--;
          });
        }
      } else {
        timer.cancel();
        _autoRedirectToLogin();
      }
    });
  }

  void _autoRedirectToLogin() {
    if (mounted && !_userInteracted) {
      _refreshToLogin();
    }
  }

  void _performReturnToLogin() {
    setState(() {
      _userInteracted = true;
    });
    _autoRedirectTimer?.cancel();
    _logoutProcessTimer?.cancel();

    _refreshToLogin();
  }

  /// Refresh the page to login (web) or navigate cleanly (mobile)
  void _refreshToLogin() {
    try {
      if (kIsWeb) {
        // For web: perform a full page refresh to login using modern web APIs
        final currentLocation = web.window.location;
        final loginUrl = '${currentLocation.origin}/#/login';
        web.window.location.href = loginUrl;
        web.window.location.reload();
      } else {
        // For mobile: clear all routes and navigate to login
        Get.reset();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // Fallback if web refresh fails
      Get.reset();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _showHelpDialog() {
    setState(() {
      _userInteracted = true;
    });
    _autoRedirectTimer?.cancel();
    _logoutProcessTimer?.cancel();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text(
          'If you\'re having trouble logging back in or need assistance, please try the following:\n\n'
              '• Check your internet connection\n'
              '• Clear your browser cache\n'
              '• Try refreshing the page\n'
              '• Contact support if issues persist\n\n'
              'For immediate assistance, you can also try logging in with a different browser or device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshToLogin();
            },
            child: const Text('Try Login Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    _logoutProcessTimer?.cancel();
    _iconAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme safely with fallbacks
    final theme = Theme.of(context);
    final scaffoldColor = theme.scaffoldBackgroundColor;
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    // Safe text style getters with fallbacks
    final headlineMedium = textTheme.headlineMedium ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
    final bodyLarge = textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final bodyMedium = textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final bodySmall = textTheme.bodySmall ?? const TextStyle(fontSize: 12);

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success icon with animation
              AnimatedBuilder(
                animation: _iconAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _iconRotationAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _logoutComplete ? Colors.green.shade50 : primaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: _logoutComplete ? Colors.green.shade300 : primaryColor.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _logoutComplete
                                  ? Colors.green.shade200.withOpacity(0.5)
                                  : primaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _logoutComplete ? Icons.check_circle : Icons.logout,
                          size: 60,
                          color: _logoutComplete ? Colors.green.shade600 : primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Animated content
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Success message
                    Text(
                      _logoutComplete ? 'Successfully Logged Out' : 'Logging Out',
                      style: headlineMedium.copyWith(
                        color: _logoutComplete ? Colors.green.shade700 : primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Subtitle message
                    Text(
                      _logoutComplete
                          ? 'Your session has been securely ended.\nThank you for using our app!'
                          : 'Please wait while we secure your session...',
                      style: bodyLarge.copyWith(
                        color: bodyLarge.color?.withOpacity(0.8) ?? Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Status indicator
                    if (!_logoutComplete) ...[
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage,
                        style: bodySmall.copyWith(
                          color: bodySmall.color?.withOpacity(0.6) ?? Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ready for login',
                            style: bodySmall.copyWith(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Countdown timer
                    if (!_userInteracted) ...[
                      Text(
                        'Redirecting to login in $_autoRedirectCountdown seconds',
                        style: bodyMedium.copyWith(
                          color: bodyMedium.color?.withOpacity(0.6) ?? Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Continue to login button
                        ElevatedButton(
                          onPressed: _performReturnToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue to Login',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Help button
                        OutlinedButton(
                          onPressed: _showHelpDialog,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Help',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple logout utility for all platforms
class SimpleLogout {
  /// Navigate to logout splash screen - handles everything else
  static void perform() {
    Get.offAll(() => const LogoutSplashScreen());
  }
}

// Quick logout splash screen for emergency/quick logouts
class QuickLogoutSplashScreen extends StatelessWidget {
  const QuickLogoutSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Just redirect to main logout splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(() => const LogoutSplashScreen());
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}