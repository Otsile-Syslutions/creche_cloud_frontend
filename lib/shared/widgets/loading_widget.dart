// lib/shared/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../features/auth/controllers/auth_controller.dart';
import 'logout_splash_screen.dart';

class LoadingScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final bool showProgress;
  final Color? backgroundColor;
  final Color? textColor;

  const LoadingScreen({
    super.key,
    this.title,
    this.message,
    this.showProgress = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon (optional)
              if (showProgress) ...[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Title
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textColor ?? Theme.of(context).textTheme.headlineSmall?.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Message
              if (message != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor?.withOpacity(0.8) ??
                          Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Reinitialization loading screen for logout process
class ReinitializationLoadingScreen extends StatefulWidget {
  const ReinitializationLoadingScreen({super.key});

  @override
  State<ReinitializationLoadingScreen> createState() => _ReinitializationLoadingScreenState();
}

class _ReinitializationLoadingScreenState extends State<ReinitializationLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late List<Animation<double>> _dotAnimations;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStatusMonitoring();
  }

  void _initializeAnimations() {
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _dotsController,
          curve: Interval(
            index * 0.2,
            (index * 0.2) + 0.4,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  void _startStatusMonitoring() {
    _statusCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        final authController = Get.find<AuthController>();
        if (authController.backgroundReinitComplete.value) {
          timer.cancel();
          _navigateToLogin();
        }
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _dotsController.dispose();
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
            children: [
              // Status icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.refresh,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Preparing Login',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Status message
              GetX<AuthController>(
                builder: (controller) {
                  return Text(
                    controller.backgroundReinitStatus.value.isEmpty
                        ? 'Setting up your login environment...'
                        : controller.backgroundReinitStatus.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const SizedBox(height: 32),

              // Animated dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _dotAnimations[index],
                    builder: (context, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(_dotAnimations[index].value),
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Progress indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Skip button (emergency exit)
              TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  'Skip and Continue',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced loading widget with better animations
class EnhancedLoadingWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final Color? color;
  final double size;
  final bool showTitle;

  const EnhancedLoadingWidget({
    super.key,
    this.title,
    this.message,
    this.color,
    this.size = 60.0,
    this.showTitle = true,
  });

  @override
  State<EnhancedLoadingWidget> createState() => _EnhancedLoadingWidgetState();
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      4,
          (index) => AnimationController(
        duration: Duration(milliseconds: 1200 + (index * 100)),
        vsync: this,
      )..repeat(reverse: true),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading rings
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(4, (index) {
                return AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Container(
                      width: widget.size - (index * 10),
                      height: widget.size - (index * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: (widget.color ?? Theme.of(context).primaryColor)
                              .withOpacity(_animations[index].value),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          if (widget.showTitle && widget.title != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Pulsing loading widget
class PulsingLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const PulsingLoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 80.0,
  });

  @override
  State<PulsingLoadingWidget> createState() => _PulsingLoadingWidgetState();
}

class _PulsingLoadingWidgetState extends State<PulsingLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (widget.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                          (widget.color ?? Theme.of(context).primaryColor).withOpacity(0.3),
                          widget.color ?? Theme.of(context).primaryColor,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.color ?? Theme.of(context).primaryColor).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sync,
                      size: widget.size * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Dots loading widget
class DotsLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final int dotCount;
  final double dotSize;

  const DotsLoadingWidget({
    super.key,
    this.message,
    this.color,
    this.dotCount = 5,
    this.dotSize = 12.0,
  });

  @override
  State<DotsLoadingWidget> createState() => _DotsLoadingWidgetState();
}

class _DotsLoadingWidgetState extends State<DotsLoadingWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(widget.dotCount, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.dotCount, (index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (widget.color ?? Theme.of(context).primaryColor)
                          .withOpacity(_animations[index].value),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.color ?? Theme.of(context).primaryColor)
                              .withOpacity(_animations[index].value * 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Utility class for loading screen routes
class LoadingScreenRoutes {
  static const String reinitialization = '/loading/reinitialization';
  static const String general = '/loading/general';
  static const String enhanced = '/loading/enhanced';
  static const String logoutSplash = '/logout/splash';

  static Route<T> createRoute<T extends Object?>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => screen,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> createSplashRoute<T extends Object?>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => screen,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
    );
  }
}

// Extension for easy loading screen navigation
extension LoadingScreenNavigation on GetInterface {
  /// Show logout splash screen (primary logout method)
  void toLogoutSplash() {
    Get.offAll(
          () => const LogoutSplashScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  /// Show quick logout splash screen
  void toQuickLogoutSplash() {
    Get.offAll(
          () => const QuickLogoutSplashScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// Show reinitialization loading screen (kept for compatibility)
  void toReinitializationLoading() {
    Get.to(
          () => const ReinitializationLoadingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// Show enhanced loading screen with progress estimation
  void toEnhancedLoadingScreen({
    String? title,
    String? message,
    Color? color,
  }) {
    Get.to(
          () => Scaffold(
        body: EnhancedLoadingWidget(
          title: title ?? 'Loading',
          message: message ?? 'Please wait...',
          color: color,
        ),
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }
}