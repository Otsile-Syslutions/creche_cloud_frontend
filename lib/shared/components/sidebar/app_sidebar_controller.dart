// lib/shared/components/sidebar/app_sidebar_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppSidebarController extends GetxController with GetSingleTickerProviderStateMixin {
  // Observable states
  final RxBool isExpanded = true.obs;
  final RxInt selectedIndex = 0.obs;
  final RxDouble sidebarWidth = 250.0.obs;
  final RxDouble collapsedWidth = 70.0.obs;

  // Animation controller
  late AnimationController animationController;
  late Animation<double> widthAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> rotationAnimation;

  // Scroll controller for menu items
  final ScrollController menuScrollController = ScrollController();

  // Focus nodes for keyboard navigation
  final List<FocusNode> menuItemFocusNodes = [];
  FocusNode? toggleButtonFocusNode;

  // Responsive breakpoints
  static const double minHeightForScroll = 676.0;
  static const double maxItemsBeforeScroll = 8;

  @override
  void onInit() {
    super.onInit();

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Setup animations
    widthAnimation = Tween<double>(
      begin: collapsedWidth.value,
      end: sidebarWidth.value,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize with expanded state
    if (isExpanded.value) {
      animationController.value = 1.0;
    }

    // Initialize focus node for toggle button
    toggleButtonFocusNode = FocusNode();

    // Listen to expansion changes
    ever(isExpanded, (_) {
      if (isExpanded.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    menuScrollController.dispose();
    toggleButtonFocusNode?.dispose();
    for (var node in menuItemFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  // Toggle sidebar expansion
  void toggleSidebar() {
    isExpanded.value = !isExpanded.value;
  }

  // Set selected menu item
  void selectMenuItem(int index) {
    selectedIndex.value = index;

    // Ensure selected item is visible in scroll view
    if (menuScrollController.hasClients) {
      final itemHeight = 56.0; // Approximate height of menu item
      final targetPosition = index * itemHeight;
      final viewportHeight = menuScrollController.position.viewportDimension;

      if (targetPosition < menuScrollController.offset ||
          targetPosition > menuScrollController.offset + viewportHeight - itemHeight) {
        menuScrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Check if scrolling is needed based on height and item count
  bool shouldEnableScroll(double availableHeight, int itemCount) {
    if (availableHeight < minHeightForScroll) return true;
    if (itemCount > maxItemsBeforeScroll) return true;

    // Calculate approximate total height needed
    const itemHeight = 56.0; // Approximate height per item
    const headerHeight = 200.0; // Header with logo
    const footerHeight = 80.0; // Footer section
    const padding = 32.0; // Top and bottom padding

    final totalNeededHeight = headerHeight + footerHeight + (itemCount * itemHeight) + padding;

    return totalNeededHeight > availableHeight;
  }

  // Handle keyboard navigation
  void handleKeyboardNavigation(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) {
      navigateToPreviousItem();
    } else if (key == LogicalKeyboardKey.arrowDown) {
      navigateToNextItem();
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      // Trigger selected item action
      onMenuItemTap(selectedIndex.value);
    }
  }

  void navigateToPreviousItem() {
    if (selectedIndex.value > 0) {
      selectMenuItem(selectedIndex.value - 1);
      menuItemFocusNodes[selectedIndex.value].requestFocus();
    }
  }

  void navigateToNextItem() {
    if (selectedIndex.value < menuItemFocusNodes.length - 1) {
      selectMenuItem(selectedIndex.value + 1);
      menuItemFocusNodes[selectedIndex.value].requestFocus();
    }
  }

  // Initialize focus nodes for menu items
  void initializeFocusNodes(int itemCount) {
    // Clear existing nodes
    for (var node in menuItemFocusNodes) {
      node.dispose();
    }
    menuItemFocusNodes.clear();

    // Create new nodes
    for (int i = 0; i < itemCount; i++) {
      menuItemFocusNodes.add(FocusNode());
    }
  }

  // Callback for menu item tap (to be overridden by specific implementations)
  void onMenuItemTap(int index) {
    // This will be overridden by specific platform controllers
  }

  // Update responsive width based on screen size
  void updateResponsiveWidth(double screenWidth) {
    if (screenWidth < 1200) {
      sidebarWidth.value = 220.0;
      collapsedWidth.value = 60.0;
    } else if (screenWidth < 1600) {
      sidebarWidth.value = 240.0;
      collapsedWidth.value = 65.0;
    } else {
      sidebarWidth.value = 250.0;
      collapsedWidth.value = 70.0;
    }

    // Update animation if needed
    widthAnimation = Tween<double>(
      begin: collapsedWidth.value,
      end: sidebarWidth.value,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }
}