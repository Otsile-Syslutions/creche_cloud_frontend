// lib/features/parent_platform/config/sidebar/parent_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart' hide SidebarXItem;
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';

class ParentMenuItems {
  static List<AppSidebarItem> getMenuItems() {
    return [
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Home',
        onTap: () {
          // Navigate to parent home
          // Get.toNamed(AppRoutes.parentHome);
        },
      ),
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedBaby01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'My Children',
        onTap: () {
          // Navigate to children
          // Get.toNamed(AppRoutes.parentChildren);
        },
      ),
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedImage01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Daily Photos',
        onTap: () {
          // Navigate to photos/activities
          // Get.toNamed(AppRoutes.parentActivities);
        },
      ),
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedMessage01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Messages',
        onTap: () {
          // Navigate to messages
          // Get.toNamed(AppRoutes.parentMessages);
        },
      ),
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedFile02,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Reports',
        onTap: () {
          // Navigate to reports
          // Get.toNamed(AppRoutes.parentReports);
        },
      ),
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedInvoice,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Billing',
        onTap: () {
          // Navigate to billing
          // Get.toNamed(AppRoutes.parentBilling);
        },
      ),
    ];
  }

  static Widget buildHeader({SidebarXController? controller}) {
    return AppSidebarHeader(
      controller: controller,
    );
  }

  static Widget buildFooter() {
    // Simple static footer without GetBuilder
    return const AppSidebarFooter(
      statusText: 'Parent Portal',
      isActive: true,
      statusIcon: Icons.child_care,
    );
  }

  // New method to build dynamic footer (to be called from parent widget that has access to AuthController)
  static Widget buildDynamicFooter({required int childCount}) {
    return AppSidebarFooter(
      statusText: childCount > 0
          ? '$childCount ${childCount == 1 ? 'Child' : 'Children'}'
          : 'No Children',
      isActive: childCount > 0,
      statusIcon: Icons.child_care,
    );
  }
}