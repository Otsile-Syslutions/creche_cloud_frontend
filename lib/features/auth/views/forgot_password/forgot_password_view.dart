// lib/features/auth/views/forgot_password/forgot_password_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/forgot_password_view_mobile.dart';
import 'responsive/forgot_password_view_tablet.dart';
import 'responsive/forgot_password_view_desktop.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: ForgotPasswordViewMobile(),
      tablet: ForgotPasswordViewTablet(),
      desktop: ForgotPasswordViewDesktop(),
    );
  }
}