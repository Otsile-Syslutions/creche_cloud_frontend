// lib/shared/components/sidebar/app_sidebar_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/app_logger.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/auth/models/tenant_model.dart';
import '../../../features/auth/models/user_model.dart';

class AppSidebarController extends GetxController with GetSingleTickerProviderStateMixin {
  // Observable states - Initialize with default values
  final RxBool isExpanded = true.obs;
  final RxInt selectedIndex = 0.obs;
  final RxDouble sidebarWidth = 250.0.obs;
  final RxDouble collapsedWidth = 85.0.obs;

  // Submenu expansion states - track which menu items are expanded
  final RxMap<int, bool> expandedMenuItems = <int, bool>{}.obs;

  // User information observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<TenantModel?> currentTenant = Rx<TenantModel?>(null);
  final RxString userName = 'Guest User'.obs;
  final RxString userRole = 'Not logged in'.obs;
  final RxString userInitials = 'G'.obs;
  final RxString userPhotoUrl = ''.obs;
  final RxBool isUserDataLoaded = false.obs;

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

  // Add a flag to track if controller is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Controller tag for identification
  String? controllerTag;

  // Auth controller reference
  AuthController? _authController;

  @override
  void onInit() {
    super.onInit();

    try {
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
        if (animationController.isAnimating) return;
        if (isExpanded.value) {
          animationController.forward();
        } else {
          animationController.reverse();
          // Collapse all submenus when sidebar is collapsed
          expandedMenuItems.clear();
        }
      });

      // Initialize user data
      _initializeUserData();

      _isInitialized = true;
    } catch (e) {
      AppLogger.e('Error initializing AppSidebarController', e);
      _isInitialized = false;
    }
  }

  // Toggle submenu expansion
  void toggleSubmenu(int index) {
    if (!_isInitialized) return;

    // Only allow submenu expansion when sidebar is expanded
    if (!isExpanded.value) {
      // If sidebar is collapsed, expand it first
      isExpanded.value = true;
      // Then expand the submenu after a delay
      Future.delayed(const Duration(milliseconds: 300), () {
        expandedMenuItems[index] = !(expandedMenuItems[index] ?? false);
      });
    } else {
      expandedMenuItems[index] = !(expandedMenuItems[index] ?? false);
    }
  }

  // Check if a menu item is expanded
  bool isMenuItemExpanded(int index) {
    return expandedMenuItems[index] ?? false;
  }

  // Select a submenu item
  void selectSubmenuItem(int parentIndex, int subIndex) {
    if (!_isInitialized) return;

    // Expand parent if not already expanded
    if (!isMenuItemExpanded(parentIndex)) {
      expandedMenuItems[parentIndex] = true;
    }

    // Set selected index using a combined index (e.g., parentIndex * 100 + subIndex)
    selectedIndex.value = parentIndex * 100 + subIndex;
  }

  void _initializeUserData() {
    try {
      // Get or initialize auth controller
      if (Get.isRegistered<AuthController>()) {
        _authController = Get.find<AuthController>();
      } else {
        _authController = Get.put(AuthController());
      }

      // Initial load of user data
      _updateUserData();

      // Listen to auth controller changes
      if (_authController != null) {
        // Listen to user changes
        ever(_authController!.currentUser, (_) {
          _updateUserData();
        });

        // Listen to tenant changes
        ever(_authController!.currentTenant, (_) {
          _updateUserData();
        });

        // Listen to initialization status
        ever(_authController!.isInitialized, (initialized) {
          if (initialized) {
            _updateUserData();
          }
        });
      }
    } catch (e) {
      AppLogger.e('Error initializing user data in AppSidebarController', e);
      _setDefaultUserData();
    }
  }

  void _updateUserData() {
    try {
      if (_authController == null || !_authController!.isInitialized.value) {
        _setDefaultUserData();
        return;
      }

      final user = _authController!.currentUser.value;
      final tenant = _authController!.currentTenant.value;

      if (user == null) {
        _setDefaultUserData();
        return;
      }

      // Update user observables
      currentUser.value = user;
      currentTenant.value = tenant;

      // Update display values
      userName.value = user.fullName.trim().isNotEmpty ? user.fullName : 'User';
      userRole.value = _getUserRoleDisplay(user, tenant);
      userInitials.value = _getUserInitials(user);
      userPhotoUrl.value = user.profileImage ?? '';
      isUserDataLoaded.value = true;

      AppLogger.d('User data updated in AppSidebarController: ${userName.value}');
    } catch (e) {
      AppLogger.e('Error updating user data in AppSidebarController', e);
      _setDefaultUserData();
    }
  }

  void _setDefaultUserData() {
    currentUser.value = null;
    currentTenant.value = null;
    userName.value = 'Guest User';
    userRole.value = 'Not logged in';
    userInitials.value = 'G';
    userPhotoUrl.value = '';
    isUserDataLoaded.value = false;
  }

  String _getUserInitials(UserModel user) {
    try {
      if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
        return user.initials;
      } else if (user.firstName.isNotEmpty) {
        return user.firstName[0].toUpperCase();
      } else if (user.lastName.isNotEmpty) {
        return user.lastName[0].toUpperCase();
      } else if (user.email.isNotEmpty) {
        return user.email[0].toUpperCase();
      }
    } catch (e) {
      // Fallback if any error occurs
    }
    return 'U';
  }

  String _getUserRoleDisplay(UserModel user, TenantModel? tenant) {
    if (user.isPlatformAdmin) {
      return 'Platform Admin';
    }

    if (user.platformType == 'tenant' && tenant != null) {
      return tenant.displayName;
    }

    return user.primaryRole;
  }

  // Method to manually refresh user data
  void refreshUserData() {
    _updateUserData();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh user data when controller is ready
    _updateUserData();
  }

  @override
  void onClose() {
    try {
      animationController.dispose();
      menuScrollController.dispose();
      toggleButtonFocusNode?.dispose();
      for (var node in menuItemFocusNodes) {
        node.dispose();
      }
    } catch (e) {
      AppLogger.e('Error disposing AppSidebarController', e);
    }
    super.onClose();
  }

  // Toggle sidebar expansion
  void toggleSidebar() {
    if (!_isInitialized) return;
    isExpanded.value = !isExpanded.value;
  }

  // Set selected menu item
  void selectMenuItem(int index) {
    if (!_isInitialized) return;

    // Validate index
    if (index < 0 || index >= menuItemFocusNodes.length) {
      selectedIndex.value = 0;
      return;
    }

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
    if (!_isInitialized) return;

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
    if (!_isInitialized) return;

    if (selectedIndex.value > 0) {
      selectMenuItem(selectedIndex.value - 1);
      if (selectedIndex.value < menuItemFocusNodes.length) {
        menuItemFocusNodes[selectedIndex.value].requestFocus();
      }
    }
  }

  void navigateToNextItem() {
    if (!_isInitialized) return;

    if (selectedIndex.value < menuItemFocusNodes.length - 1) {
      selectMenuItem(selectedIndex.value + 1);
      if (selectedIndex.value < menuItemFocusNodes.length) {
        menuItemFocusNodes[selectedIndex.value].requestFocus();
      }
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
    if (!_isInitialized) return;

    if (screenWidth < 1200) {
      sidebarWidth.value = 220.0;
      collapsedWidth.value = 85.0;
    } else if (screenWidth < 1600) {
      sidebarWidth.value = 240.0;
      collapsedWidth.value = 85.0;
    } else {
      sidebarWidth.value = 250.0;
      collapsedWidth.value = 85.0;
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