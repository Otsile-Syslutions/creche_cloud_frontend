// lib/features/auth/views/sign_up/components/sign_up_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../controllers/signup_form_controller.dart';
import '../../login/controllers/login_form_controller.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/responsive/responsive_layout_helper.dart';

class SignUpForm extends GetView<SignUpFormController> {
  const SignUpForm({super.key});

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
        final contentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24).responsive(context);

        // CRITICAL FIX: Generate unique GlobalKey in build method instead of controller
        return Builder(
          builder: (context) {
            // Generate a fresh GlobalKey every time this widget builds
            final formKey = GlobalKey<FormState>(
                debugLabel: 'signUpForm_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}_${context.hashCode}'
            );

            return Form(
              key: formKey, // Always gets a completely fresh unique key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Name Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: SizedBox(
                      height: fieldHeight,
                      child: _buildAnimatedField(
                        animation: controller.firstNameShakeAnimation,
                        child: _buildTextFormField(
                          context: context,
                          controller: controller.firstNameController,
                          errorObservable: controller.firstNameError,
                          labelText: 'First Name',
                          hintText: 'Enter your first name',
                          keyboardType: TextInputType.name,
                          focusColor: focusColor,
                          errorColor: errorColor,
                          fontSize: fontSize,
                          borderRadius: borderRadius,
                          regularBorderRadius: regularBorderRadius,
                          contentPadding: contentPadding,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Last Name Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: SizedBox(
                      height: fieldHeight,
                      child: _buildAnimatedField(
                        animation: controller.lastNameShakeAnimation,
                        child: _buildTextFormField(
                          context: context,
                          controller: controller.lastNameController,
                          errorObservable: controller.lastNameError,
                          labelText: 'Last Name',
                          hintText: 'Enter your last name',
                          keyboardType: TextInputType.name,
                          focusColor: focusColor,
                          errorColor: errorColor,
                          fontSize: fontSize,
                          borderRadius: borderRadius,
                          regularBorderRadius: regularBorderRadius,
                          contentPadding: contentPadding,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Email Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: SizedBox(
                      height: fieldHeight,
                      child: _buildAnimatedField(
                        animation: controller.signUpEmailShakeAnimation,
                        child: _buildTextFormField(
                          context: context,
                          controller: controller.signUpEmailController,
                          errorObservable: controller.signUpEmailError,
                          labelText: AppStrings.email,
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          focusColor: focusColor,
                          errorColor: errorColor,
                          fontSize: fontSize,
                          borderRadius: borderRadius,
                          regularBorderRadius: regularBorderRadius,
                          contentPadding: contentPadding,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Password Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: SizedBox(
                      height: fieldHeight,
                      child: _buildAnimatedField(
                        animation: controller.signUpPasswordShakeAnimation,
                        child: _buildPasswordField(
                          context: context,
                          controller: controller.signUpPasswordController,
                          errorObservable: controller.signUpPasswordError,
                          showPasswordObservable: controller.showSignUpPassword,
                          onToggleVisibility: controller.toggleSignUpPasswordVisibility,
                          labelText: AppStrings.password,
                          hintText: 'Enter a secure password',
                          focusColor: focusColor,
                          errorColor: errorColor,
                          fontSize: fontSize,
                          borderRadius: borderRadius,
                          regularBorderRadius: regularBorderRadius,
                          contentPadding: contentPadding,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Confirm Password Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: SizedBox(
                      height: fieldHeight,
                      child: _buildAnimatedField(
                        animation: controller.confirmSignUpPasswordShakeAnimation,
                        child: _buildPasswordField(
                          context: context,
                          controller: controller.confirmSignUpPasswordController,
                          errorObservable: controller.confirmSignUpPasswordError,
                          showPasswordObservable: controller.showConfirmSignUpPassword,
                          onToggleVisibility: controller.toggleConfirmSignUpPasswordVisibility,
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          focusColor: focusColor,
                          errorColor: errorColor,
                          fontSize: fontSize,
                          borderRadius: borderRadius,
                          regularBorderRadius: regularBorderRadius,
                          contentPadding: contentPadding,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.0.responsivePadding(context)),

                  // Terms and Conditions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: Row(
                      children: [
                        Obx(() => Transform.scale(
                          scale: ResponsiveLayoutHelper.scale(context, 0.8, minValue: 0.6, maxValue: 1.0),
                          child: Checkbox(
                            value: controller.acceptTerms.value,
                            onChanged: (value) => controller.toggleAcceptTerms(),
                            activeColor: AppColors.signupPink,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )),
                        SizedBox(width: 8.0.responsivePadding(context)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'I accept the ',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.0.responsiveFont(context),
                                    color: AppColors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.0.responsiveFont(context),
                                    color: AppColors.signupPink,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.0.responsivePadding(context)),

                  // Sign Up Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: Obx(() => SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: authController.isLoading.value ? null : () {
                          authController.signUp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.signupPink,
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
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0.responsiveFont(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )),
                  ),

                  SizedBox(height: 24.0.responsivePadding(context)),

                  // Back to Login
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: centerPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0.responsiveFont(context),
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(width: 8.0.responsivePadding(context)),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.login),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.0.responsiveFont(context),
                              color: AppColors.loginButton,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
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

  Widget _buildTextFormField({
    required BuildContext context,
    required TextEditingController controller,
    required RxString errorObservable,
    required String labelText,
    required String hintText,
    required TextInputType keyboardType,
    required Color focusColor,
    required Color errorColor,
    required double fontSize,
    required double borderRadius,
    required double regularBorderRadius,
    required EdgeInsets contentPadding,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return Obx(() {
            final hasError = errorObservable.value.isNotEmpty;

            return TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: (_) => null, // We handle validation manually
              maxLines: 1,
              onChanged: (value) {
                // Trigger rebuild when content changes
                (context as Element).markNeedsBuild();
              },
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: fontSize,
                color: hasError
                    ? errorColor
                    : (hasFocus ? Colors.black : AppColors.textPrimary),
              ),
              decoration: InputDecoration(
                hintText: hasError
                    ? errorObservable.value
                    : (hasFocus ? hintText : null),
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: hasError ? errorColor : Colors.grey.shade400,
                  fontSize: fontSize,
                ),
                labelText: (!hasFocus && !hasError) ? labelText : null,
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
            );
          });
        },
      ),
    );
  }

  /// Navigate back to login with proper focus management
  void _navigateBackToLogin() {
    // Navigate to login
    Get.toNamed(AppRoutes.login);

    // Focus email field when returning to login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          // Get the login controller and call onReturnToView
          final loginController = Get.find<LoginFormController>();
          loginController.onReturnToView();
        } catch (e) {
          // Controller might not be ready yet, fallback to direct focus
          Future.delayed(const Duration(milliseconds: 200), () {
            try {
              Get.find<LoginFormController>().focusEmailField();
            } catch (e) {
              // Ignore if controller is not available
            }
          });
        }
      });
    });
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required RxString errorObservable,
    required RxBool showPasswordObservable,
    required VoidCallback onToggleVisibility,
    required String labelText,
    required String hintText,
    required Color focusColor,
    required Color errorColor,
    required double fontSize,
    required double borderRadius,
    required double regularBorderRadius,
    required EdgeInsets contentPadding,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return Obx(() {
            final hasError = errorObservable.value.isNotEmpty;

            return TextFormField(
              controller: controller,
              obscureText: !showPasswordObservable.value,
              validator: (_) => null, // We handle validation manually
              maxLines: 1,
              onChanged: (value) {
                // Trigger rebuild when content changes
                (context as Element).markNeedsBuild();
              },
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: fontSize,
                color: hasError
                    ? errorColor
                    : (hasFocus ? Colors.black : AppColors.textPrimary),
              ),
              decoration: InputDecoration(
                hintText: hasError
                    ? errorObservable.value
                    : (hasFocus ? hintText : null),
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: hasError ? errorColor : Colors.grey.shade400,
                  fontSize: fontSize,
                ),
                labelText: (!hasFocus && !hasError) ? labelText : null,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                  fontSize: fontSize * 0.9,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPasswordObservable.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: hasError ? errorColor : AppColors.textSecondary,
                    size: 20.0.responsiveIcon(context),
                  ),
                  onPressed: onToggleVisibility,
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
            );
          });
        },
      ),
    );
  }
}