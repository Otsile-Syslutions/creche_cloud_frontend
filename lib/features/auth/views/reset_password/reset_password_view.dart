// lib/features/auth/views/reset_password/reset_password_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/reset_password_view_mobile.dart';
import 'responsive/reset_password_view_tablet.dart';
import 'responsive/reset_password_view_desktop.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: ResetPasswordViewMobile(),
      tablet: ResetPasswordViewTablet(),
      desktop: ResetPasswordViewDesktop(),
    );
  }
}