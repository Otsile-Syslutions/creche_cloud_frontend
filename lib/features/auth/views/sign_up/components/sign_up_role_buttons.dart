// lib/features/auth/views/sign_up/components/sign_up_role_buttons.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/sign_up_role_buttons_controller.dart';

class SignUpRoleButtons extends StatelessWidget {
  final double buttonFontSize;
  final double scaleFactor;
  final double verticalSpacing;

  const SignUpRoleButtons({
    super.key,
    required this.buttonFontSize,
    required this.scaleFactor,
    required this.verticalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpRoleController());

    return Column(
      children: [
        _buildRoleButton(
          context,
          _buildOwnerDirectorText,
              () => controller.handleRoleSelection('owner'),
          scaleFactor,
          'owner',
        ),
        SizedBox(height: verticalSpacing * 0.8),
        _buildRoleButton(
          context,
          _buildStaffMemberText,
              () => controller.handleRoleSelection('staff'),
          scaleFactor,
          'staff',
        ),
        SizedBox(height: verticalSpacing * 0.8),
        _buildRoleButton(
          context,
          _buildParentGuardianText,
              () => controller.handleRoleSelection('parent'),
          scaleFactor,
          'parent',
        ),
      ],
    );
  }

  Widget _buildOwnerDirectorText(bool isHovered) {
    final defaultTextColor = Colors.grey.shade700; // Medium dark grey for default
    final highlightColor = isHovered ? Colors.white : Colors.grey.shade800; // Darker grey for prominent words
    final normalColor = isHovered ? Colors.white : defaultTextColor;
    final fontSize = isHovered ? buttonFontSize + 2 : buttonFontSize; // Increase font size on hover

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: normalColor,
        ),
        children: [
          const TextSpan(text: "I'm a "),
          TextSpan(
            text: "ECD owner",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlightColor,
              letterSpacing: 0.8, // Wider letter spacing
            ),
          ),
          const TextSpan(text: " or "),
          TextSpan(
            text: "director",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlightColor,
              letterSpacing: 0.8, // Wider letter spacing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffMemberText(bool isHovered) {
    final defaultTextColor = Colors.grey.shade700; // Medium dark grey for default
    final highlightColor = isHovered ? Colors.white : Colors.grey.shade800; // Darker grey for prominent words
    final normalColor = isHovered ? Colors.white : defaultTextColor;
    final fontSize = isHovered ? buttonFontSize + 2 : buttonFontSize; // Increase font size on hover

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: normalColor,
        ),
        children: [
          const TextSpan(text: "I'm a "),
          TextSpan(
            text: "staff member",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlightColor,
              letterSpacing: 0.8, // Wider letter spacing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentGuardianText(bool isHovered) {
    final defaultTextColor = Colors.grey.shade700; // Medium dark grey for default
    final highlightColor = isHovered ? Colors.white : Colors.grey.shade800; // Darker grey for prominent words
    final normalColor = isHovered ? Colors.white : defaultTextColor;
    final fontSize = isHovered ? buttonFontSize + 2 : buttonFontSize; // Increase font size on hover

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: normalColor,
        ),
        children: [
          const TextSpan(text: "I'm a "),
          TextSpan(
            text: "parent",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlightColor,
              letterSpacing: 0.8, // Wider letter spacing
            ),
          ),
          const TextSpan(text: " or "),
          TextSpan(
            text: "guardian",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlightColor,
              letterSpacing: 0.8, // Wider letter spacing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context,
      Widget Function(bool) textBuilder,
      VoidCallback onPressed,
      double scaleFactor,
      String role,
      ) {
    final controller = Get.find<SignUpRoleController>();

    return Obx(() {
      bool isHovered = false;

      switch (role) {
        case 'owner':
          isHovered = controller.isOwnerHovered.value;
          break;
        case 'staff':
          isHovered = controller.isStaffHovered.value;
          break;
        case 'parent':
          isHovered = controller.isParentHovered.value;
          break;
      }

      return MouseRegion(
        onEnter: (_) {
          switch (role) {
            case 'owner':
              controller.onOwnerButtonHover(true);
              break;
            case 'staff':
              controller.onStaffButtonHover(true);
              break;
            case 'parent':
              controller.onParentButtonHover(true);
              break;
          }
        },
        onExit: (_) {
          switch (role) {
            case 'owner':
              controller.onOwnerButtonHover(false);
              break;
            case 'staff':
              controller.onStaffButtonHover(false);
              break;
            case 'parent':
              controller.onParentButtonHover(false);
              break;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: MediaQuery.of(context).size.width * 0.35,
          height: (72 * scaleFactor).clamp(55.0, 90.0),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isHovered ? AppColors.loginButton : Colors.white,
              foregroundColor: isHovered ? Colors.white : Colors.grey.shade700,
              side: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: 20 * scaleFactor,
                vertical: 12 * scaleFactor,
              ),
            ),
            child: AnimatedScale(
              scale: controller.isButtonPressed.value ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main text content
                  Expanded(
                    child: textBuilder(isHovered),
                  ),

                  // Animated arrow on the right
                  AnimatedOpacity(
                    opacity: isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                        isHovered ? 0 : -10, // Slide in from left
                        0,
                        0,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: (18 * scaleFactor).clamp(14.0, 22.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}