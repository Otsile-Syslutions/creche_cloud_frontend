// lib/features/auth/views/login/login_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/login_view_desktop.dart';
import 'responsive/login_view_mobile.dart';
import 'responsive/login_view_tablet.dart' show LoginViewTablet;


class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: LoginViewMobile(),
      tablet: LoginViewTablet(),
      desktop: LoginViewDesktop(),
    );
  }
}