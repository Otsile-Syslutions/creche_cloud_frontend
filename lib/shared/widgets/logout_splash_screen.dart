// lib/shared/widgets/logout_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

// Modern web imports using package:web instead of dart:html
import 'package:web/web.dart' as web;

import '../../features/auth/controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

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
  Timer? _backgroundCheckTimer;
  int _autoRedirectCountdown = 30; // 30 seconds
  bool _userInteracted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAutoRedirectTimer();
    _startBackgroundCheck();
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

  void _startAutoRedirectTimer() {
    _autoRedirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_userInteracted) {
        timer.cancel();
        return;
      }

      if (_autoRedirectCountdown > 0) {
        setState(() {
          _autoRedirectCountdown--;
        });
      } else {
        timer.cancel();
        _autoRedirectToLogin();
      }
    });
  }

  void _startBackgroundCheck() {
    // Check background reinitialization status
    _backgroundCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_userInteracted) {
        timer.cancel();
        return;
      }

      try {
        final authController = Get.find<AuthController>();
        if (authController.backgroundReinitComplete.value) {
          timer.cancel();
          // Wait a bit more for stability, then redirect
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_userInteracted) {
              _refreshToLogin();
            }
          });
        }
      } catch (e) {
        // AuthController not available, continue with timer-based redirect
      }
    });
  }

  void _autoRedirectToLogin() {
    if (mounted && !_userInteracted) {
      _refreshToLogin();
    }
  }

  void _performReturnToLogin() {
    try {
      setState(() {
        _userInteracted = true;
      });
      _autoRedirectTimer?.cancel();
      _backgroundCheckTimer?.cancel();

      // Ensure reinitialization is complete before navigating
      _ensureReinitializationComplete().then((_) {
        if (mounted) {
          _refreshToLogin();
        }
      });
    } catch (e) {
      // Fallback navigation
      Get.snackbar(
        'Navigation Error',
        'Please restart the app.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Fallback navigation after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _refreshToLogin();
        }
      });
    }
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

  Future<void> _ensureReinitializationComplete() async {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.backgroundReinitComplete.value) {
        // Force completion
        await authController.ensureLoginReady();
      }
    } catch (e) {
      // Continue without auth controller
    }
  }

  void _showHelpDialog() {
    setState(() {
      _userInteracted = true;
    });
    _autoRedirectTimer?.cancel();
    _backgroundCheckTimer?.cancel();

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
    _backgroundCheckTimer?.cancel();
    _iconAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          color: Colors.green.shade50,
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade200.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green.shade600,
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
                      'Successfully Logged Out',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Subtitle message
                    Text(
                      'Your session has been securely ended.\nThank you for using our app!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Background status indicator
                    GetX<AuthController>(
                      builder: (controller) {
                        if (controller.isBackgroundReinitializing.value) {
                          return Column(
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.backgroundReinitStatus.value.isEmpty
                                    ? 'Preparing login environment...'
                                    : controller.backgroundReinitStatus.value,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        } else if (controller.backgroundReinitComplete.value) {
                          return Row(
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Countdown timer
                    if (!_userInteracted) ...[
                      Text(
                        'Redirecting to login in $_autoRedirectCountdown seconds',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                            backgroundColor: Theme.of(context).primaryColor,
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

// Background reinitialization status widget
class BackgroundReinitializationStatus extends StatelessWidget {
  const BackgroundReinitializationStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(
      builder: (controller) {
        final isReinitializing = controller.isBackgroundReinitializing.value;
        final status = controller.backgroundReinitStatus.value;
        final isComplete = controller.backgroundReinitComplete.value;

        if (isComplete && status.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Login environment ready',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (isReinitializing) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    status.isEmpty ? 'Preparing...' : status,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// Quick logout splash screen for emergency/quick logouts
class QuickLogoutSplashScreen extends StatelessWidget {
  const QuickLogoutSplashScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    // Auto-redirect after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (context.mounted) {
        _refreshToLogin();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Logged Out',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Redirecting to login...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// Silent logout (no splash, direct refresh)
class SilentLogout {
  static void perform() {
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
}

// Logout utility methods
class LogoutUtils {
  /// Refresh the page to login (web) or navigate cleanly (mobile)
  static void _refreshToLogin() {
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

  /// Show standard logout splash and redirect
  static void showLogoutSplash() {
    Get.off(() => const LogoutSplashScreen());
  }

  /// Show quick logout splash and redirect
  static void showQuickLogoutSplash() {
    Get.off(() => const QuickLogoutSplashScreen());
  }

  /// Perform silent logout (no splash)
  static void performSilentLogout() {
    SilentLogout.perform();
  }

  /// Perform immediate refresh to login
  static void refreshToLogin() {
    _refreshToLogin();
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}