// lib/features/auth/views/login/components/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/login_form_controller.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/responsive/responsive_layout_helper.dart';

class LoginForm extends GetView<LoginFormController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Get auth controller
    final AuthController authController = Get.find<AuthController>();

    // Define colors for different states
    const Color focusColor = Color(0xFFFFD54F);
    const Color errorColor = Colors.red;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive field width (60% of available width)
        final fieldWidth = constraints.maxWidth * 0.6;
        final centerPadding = (constraints.maxWidth - fieldWidth) / 2;

        // Responsive values using the helper
        final fieldHeight = 55.0.responsive(context);
        final verticalSpacing = 20.0.responsivePadding(context);
        final buttonHeight = 55.0.responsive(context);
        final fontSize = 16.0.responsiveFont(context);
        final borderRadius = 35.0.responsive(context);
        final regularBorderRadius = 12.0.responsive(context);
        final contentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 20).responsive(context);

        // Calculate social button font size to match remember me and recover password
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final minScreenSize = screenWidth < screenHeight ? screenWidth : screenHeight;
        final scaleFactor = minScreenSize / 1000; // Same as login_view_desktop.dart
        final signupFontSize = (14 * scaleFactor).clamp(12.0, 18.0); // Match "Don't have an account"
        final socialButtonFontSize = signupFontSize; // Use same font size
        final toggleScale = (socialButtonFontSize / 20.0).clamp(0.5, 0.8); // Smaller toggle proportionate to text

        // More aggressive responsive scaling for social buttons
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

        // Aggressive font scaling for social buttons
        final socialFontSize = isSmallScreen
            ? (10 * scaleFactor).clamp(8.0, 12.0)
            : isMediumScreen
            ? (12 * scaleFactor).clamp(10.0, 14.0)
            : (14 * scaleFactor).clamp(12.0, 16.0);

        // Responsive spacing between social buttons
        final socialButtonSpacing = isSmallScreen
            ? 4.0.responsivePadding(context)
            : 8.0.responsivePadding(context);

        // Check if we need scroll view for small heights
        final needsScrollView = screenHeight < 677;

        final formContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field with Focus Detection and Shake Animation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              child: SizedBox(
                height: fieldHeight,
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: Obx(() {
                    final hasError = controller.emailError.value.isNotEmpty;
                    // Listen to focus changes directly from the focus node
                    return AnimatedBuilder(
                      animation: controller.emailFocusNode,
                      builder: (context, child) {
                        final hasFocus = controller.emailFocusNode.hasFocus;

                        return _buildAnimatedField(
                          animation: controller.emailShakeAnimation,
                          child: Stack(
                            children: [
                              // Text Field
                              TextFormField(
                                controller: controller.emailController,
                                focusNode: controller.emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: (_) => null, // We handle validation manually
                                maxLines: 1,
                                onChanged: (value) {
                                  // Clear error when user starts typing
                                  if (controller.emailError.value.isNotEmpty) {
                                    controller.emailError.value = '';
                                    controller.emailErrorTimer?.cancel();
                                    controller.updateValidationErrorState();
                                  }
                                },
                                onTap: () {
                                  // Clear error when user clicks on field
                                  if (controller.emailError.value.isNotEmpty) {
                                    controller.emailError.value = '';
                                    controller.emailErrorTimer?.cancel();
                                    controller.updateValidationErrorState();
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  // Move to password field without validation here
                                  // Validation will happen in focus listener
                                  controller.focusPasswordField();
                                },
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: fontSize,
                                  color: hasError
                                      ? errorColor
                                      : (hasFocus ? Colors.black : AppColors.textPrimary),
                                ),
                                decoration: InputDecoration(
                                  hintText: hasFocus ? 'Enter your email address' : null,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey.shade400,
                                    fontSize: fontSize,
                                  ),
                                  labelText: (!hasFocus && !hasError) ? AppStrings.email : null,
                                  labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.textSecondary,
                                    fontSize: fontSize * 0.9,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(hasError || hasFocus ? borderRadius : regularBorderRadius)
                                    ),
                                    borderSide: BorderSide(
                                      color: hasError ? errorColor : Colors.grey,
                                      width: hasError ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(hasError ? borderRadius : regularBorderRadius)
                                    ),
                                    borderSide: BorderSide(
                                      color: hasError ? errorColor : Colors.grey.shade400,
                                      width: hasError ? 2 : 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                                    borderSide: BorderSide(
                                      color: hasError ? errorColor : focusColor,
                                      width: hasError ? 2 : 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: hasError
                                      ? errorColor.withOpacity(0.05)
                                      : (hasFocus
                                      ? Colors.grey.shade50
                                      : Colors.grey.shade100),
                                  contentPadding: contentPadding,
                                ),
                              ),

                              // Transparent Red Error Overlay (ONLY ERROR STATE) with Shake Animation
                              if (hasError && !hasFocus)
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: hasError && !hasFocus ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Focus the field when overlay is tapped
                                        controller.emailFocusNode.requestFocus();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: errorColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(borderRadius)
                                          ),
                                          border: Border.all(
                                            color: errorColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            controller.emailError.value,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: fontSize * 0.85,
                                              fontWeight: FontWeight.w600,
                                              color: errorColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),

            SizedBox(height: verticalSpacing),

            // Password Field with Focus Detection and Shake Animation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              child: SizedBox(
                height: fieldHeight,
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: Obx(() {
                    final hasError = controller.passwordError.value.isNotEmpty;
                    final isPasswordVisible = controller.showPassword.value; // Listen to showPassword changes
                    // Listen to focus changes directly from the focus node
                    return AnimatedBuilder(
                      animation: controller.passwordFocusNode,
                      builder: (context, child) {
                        final hasFocus = controller.passwordFocusNode.hasFocus;

                        return _buildAnimatedField(
                          animation: controller.passwordShakeAnimation,
                          child: Stack(
                            children: [
                              // Text Field
                              TextFormField(
                                controller: controller.passwordController,
                                focusNode: controller.passwordFocusNode,
                                obscureText: !isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                validator: (_) => null, // We handle validation manually
                                maxLines: 1,
                                onChanged: (value) {
                                  // Clear error when user starts typing
                                  if (controller.passwordError.value.isNotEmpty) {
                                    controller.passwordError.value = '';
                                    controller.passwordErrorTimer?.cancel();
                                    controller.updateValidationErrorState();
                                  }
                                },
                                onTap: () {
                                  // Clear error when user clicks on field
                                  if (controller.passwordError.value.isNotEmpty) {
                                    controller.passwordError.value = '';
                                    controller.passwordErrorTimer?.cancel();
                                    controller.updateValidationErrorState();
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  // Submit the form when Enter is pressed
                                  _handleFormSubmission(context);
                                },
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: fontSize,
                                  color: hasError
                                      ? errorColor
                                      : (hasFocus ? Colors.black : AppColors.textPrimary),
                                ),
                                decoration: InputDecoration(
                                  hintText: hasFocus ? 'Enter your top secret password' : null,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey.shade400,
                                    fontSize: fontSize,
                                  ),
                                  labelText: (!hasFocus && !hasError) ? AppStrings.password : null,
                                  labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.textSecondary,
                                    fontSize: fontSize * 0.9,
                                  ),
                                  suffixIcon: ExcludeFocus(
                                    child: IconButton(
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: hasError ? errorColor : AppColors.textSecondary,
                                        size: 20.0.responsiveIcon(context),
                                      ),
                                      onPressed: () => controller.togglePasswordVisibility(),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(hasError || hasFocus ? borderRadius : regularBorderRadius)
                                    ),
                                    borderSide: BorderSide(
                                      color: hasError ? errorColor : Colors.grey,
                                      width: hasError ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(hasError ? borderRadius : regularBorderRadius)
                                    ),
                                    borderSide: BorderSide(
                                      color: hasError ? errorColor : Colors.grey.shade400,
                                      width: hasError ? 2 : 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                                    borderSide: BorderSide(
                                      color: hasError ? errorColor : focusColor,
                                      width: hasError ? 2 : 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: hasError
                                      ? errorColor.withOpacity(0.05)
                                      : (hasFocus
                                      ? Colors.grey.shade50
                                      : Colors.grey.shade100),
                                  contentPadding: contentPadding,
                                ),
                              ),

                              // Transparent Red Error Overlay (ONLY ERROR STATE) with Shake Animation
                              if (hasError && !hasFocus)
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: hasError && !hasFocus ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Focus the field when overlay is tapped
                                        controller.passwordFocusNode.requestFocus();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: errorColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(borderRadius)
                                          ),
                                          border: Border.all(
                                            color: errorColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            controller.passwordError.value,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: fontSize * 0.85,
                                              fontWeight: FontWeight.w600,
                                              color: errorColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),

            SizedBox(height: 10.0.responsivePadding(context)),

            // Remember Me and Recover Password Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Enhanced Remember Me Toggle
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: Focus(
                      focusNode: controller.rememberMeFocusNode,
                      onKeyEvent: (node, event) {
                        if (event.logicalKey == LogicalKeyboardKey.space && event is KeyDownEvent) {
                          controller.toggleRememberMe();
                          _handleRememberMeToggle(context);
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: GestureDetector(
                        onTap: () {
                          controller.toggleRememberMe();
                          _handleRememberMeToggle(context);
                        },
                        child: Row(
                          children: [
                            Obx(() => Transform.scale(
                              scale: ResponsiveLayoutHelper.scale(context, toggleScale, minValue: 0.6, maxValue: 1.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  switchTheme: SwitchThemeData(
                                    trackOutlineColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return AppColors.loginButton; // Active outline color
                                      }
                                      return Colors.grey.shade300; // Lighter grey outline when off
                                    }),
                                    trackOutlineWidth: MaterialStateProperty.all(1.5),
                                  ),
                                ),
                                child: Switch(
                                  value: controller.rememberMe.value,
                                  onChanged: (value) {
                                    controller.toggleRememberMe();
                                    _handleRememberMeToggle(context);
                                  },
                                  activeColor: AppColors.loginButton,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey.shade200,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            )),
                            SizedBox(width: 8.0.responsivePadding(context)),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: socialButtonFontSize,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recover Password Link
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(4),
                    child: Focus(
                      focusNode: controller.recoverPasswordFocusNode,
                      child: _RecoverPasswordButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        fontSize: socialButtonFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.0.responsivePadding(context)),

            // Login Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              child: Obx(() => SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(5),
                  child: Focus(
                    focusNode: controller.loginButtonFocusNode,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value ? null : () {
                        _handleFormSubmission(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.loginButton,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(regularBorderRadius),
                        ),
                        elevation: 0,
                      ),
                      child: authController.isLoading.value
                          ? SizedBox(
                        width: 20.0.responsiveIcon(context),
                        height: 20.0.responsiveIcon(context),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        'Log In',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0.responsiveFont(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              )),
            ),

            SizedBox(height: 20.0.responsivePadding(context)),

            // Or Divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0.responsivePadding(context)),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0.responsiveFont(context),
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.0.responsivePadding(context)),

            // Social Login Buttons - More Responsive Layout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              child: isSmallScreen
                  ? Column(
                children: [
                  // Google Login Button (Full Width on Small Screens)
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: _SocialLoginButton(
                      onPressed: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Google login will be available soon',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                      iconPath: 'assets/icons/google_icon.png',
                      text: 'Google',
                      borderRadius: regularBorderRadius,
                      fontSize: socialFontSize,
                      height: buttonHeight,
                    ),
                  ),

                  SizedBox(height: 10.0.responsivePadding(context)),

                  // Apple Login Button (Full Width on Small Screens)
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: _SocialLoginButton(
                      onPressed: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Apple login will be available soon',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.black,
                          colorText: Colors.white,
                        );
                      },
                      iconPath: 'assets/icons/apple_icon.png',
                      text: 'Apple',
                      borderRadius: regularBorderRadius,
                      fontSize: socialFontSize,
                      height: buttonHeight,
                    ),
                  ),
                ],
              )
                  : Row(
                children: [
                  // Google Login Button
                  Expanded(
                    child: Container(
                      height: buttonHeight,
                      margin: EdgeInsets.only(right: socialButtonSpacing),
                      child: _SocialLoginButton(
                        onPressed: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Google login will be available soon',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        iconPath: 'assets/icons/google_icon.png',
                        text: isMediumScreen ? 'Google' : 'Login with Google',
                        borderRadius: regularBorderRadius,
                        fontSize: socialFontSize,
                        height: buttonHeight,
                      ),
                    ),
                  ),

                  // Apple Login Button
                  Expanded(
                    child: Container(
                      height: buttonHeight,
                      margin: EdgeInsets.only(left: socialButtonSpacing),
                      child: _SocialLoginButton(
                        onPressed: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Apple login will be available soon',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.black,
                            colorText: Colors.white,
                          );
                        },
                        iconPath: 'assets/icons/apple_icon.png',
                        text: isMediumScreen ? 'Apple' : 'Login with Apple',
                        borderRadius: regularBorderRadius,
                        fontSize: socialFontSize,
                        height: buttonHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        return FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.commit,
              child: Form(
                key: controller.loginFormKey,
                onChanged: () {
                  // Trigger autofill save when remember me is enabled
                  if (controller.rememberMe.value) {
                    Form.of(context).save();
                  }
                },
                child: needsScrollView
                    ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: formContent,
                )
                    : formContent,
              ),
            ));
      },
    );
  }

  Widget _buildAnimatedField({
    required Animation<double>? animation,
    required Widget child,
  }) {
    if (animation == null) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(animation.value, 0),
          child: child,
        );
      },
    );
  }

  void _handleRememberMeToggle(BuildContext context) {
    // If remember me is now enabled and we have credentials
    if (controller.rememberMe.value) {
      if (controller.emailController.text.isNotEmpty &&
          controller.passwordController.text.isNotEmpty) {
        // Trigger autofill save
        TextInput.finishAutofillContext();
      } else {
        // Show info about password saving
        _showPasswordSaveInfo(context);
      }
    }
  }

  void _handleFormSubmission(BuildContext context) {
    // Validate the form first
    if (controller.validateForm()) {
      // If remember me is enabled, trigger password save
      if (controller.rememberMe.value) {
        // Commit autofill context to trigger browser password save
        TextInput.finishAutofillContext();

        // Small delay to ensure autofill is processed before login
        Future.delayed(const Duration(milliseconds: 100), () {
          controller.submitForm();
        });
      } else {
        // Submit normally
        controller.submitForm();
      }
    }
  }

  void _showPasswordSaveInfo(BuildContext context) {
    Get.snackbar(
      'Remember Me Enabled',
      'Your login credentials will be saved when you sign in',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.loginButton.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.save_outlined,
        color: Colors.white,
      ),
    );
  }
}

class _RecoverPasswordButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double fontSize;

  const _RecoverPasswordButton({
    required this.onPressed,
    required this.fontSize,
  });

  @override
  State<_RecoverPasswordButton> createState() => _RecoverPasswordButtonState();
}

class _RecoverPasswordButtonState extends State<_RecoverPasswordButton> {
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
              ? AppColors.lightBlue.withOpacity(0.8) // Slightly darker blue shade on hover
              : AppColors.lightBlue,
          overlayColor: AppColors.lightBlue.withOpacity(0.1), // Light blue overlay
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          'Recover Password',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: widget.fontSize,
            color: _isHovering
                ? AppColors.lightBlue.withOpacity(0.8) // Darker blue shade on hover
                : AppColors.lightBlue, // Original blue
            decoration: TextDecoration.underline,
            decorationColor: _isHovering
                ? AppColors.lightBlue.withOpacity(0.8) // Match underline color to text
                : AppColors.lightBlue,
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final String text;
  final double borderRadius;
  final double fontSize;
  final double height;

  const _SocialLoginButton({
    required this.onPressed,
    required this.iconPath,
    required this.text,
    required this.borderRadius,
    required this.fontSize,
    required this.height,
  });

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // More aggressive responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    // Aggressive icon and padding scaling
    final iconSize = isSmallScreen
        ? 16.0.responsiveIcon(context)
        : 18.0.responsiveIcon(context);

    final horizontalPadding = isSmallScreen
        ? 6.0.responsivePadding(context)
        : isMediumScreen
        ? 8.0.responsivePadding(context)
        : 12.0.responsivePadding(context);

    final spacingBetweenIconAndText = isSmallScreen
        ? 4.0.responsivePadding(context)
        : 6.0.responsivePadding(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        height: widget.height,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: _isHovering ? AppColors.signupPink : Colors.grey.shade500,
            elevation: 0.25,
            shadowColor: _isHovering
                ? AppColors.signupPink.withOpacity(0.3)
                : Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.iconPath,
                width: iconSize,
                height: iconSize,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    widget.iconPath.contains('google') ? Icons.g_mobiledata : Icons.apple,
                    size: iconSize,
                    color: widget.iconPath.contains('google') ? Colors.red : Colors.black,
                  );
                },
              ),
              if (widget.text.isNotEmpty) SizedBox(width: spacingBetweenIconAndText),
              if (widget.text.isNotEmpty)
                Flexible(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                      color: _isHovering ? AppColors.signupPink : Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}