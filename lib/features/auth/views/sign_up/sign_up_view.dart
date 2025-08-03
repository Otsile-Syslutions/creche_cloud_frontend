// lib/features/auth/views/sign_up/sign_up_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/sign_up_view_mobile.dart';
import 'responsive/sign_up_view_tablet.dart';
import 'responsive/sign_up_view_desktop.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: SignUpViewMobile(),
      tablet: SignUpViewTablet(),
      desktop: SignUpViewDesktop(),
    );
  }
}