// lib/bindings/initial_binding.dart
import 'global_bindings.dart';


/// Initial binding that extends GlobalBindings
/// This ensures all core dependencies are available at app startup
class InitialBinding extends GlobalBindings {
  @override
  void dependencies() {
    // Call parent to initialize global dependencies
    super.dependencies();

    // Add any additional app-specific initialization here if needed
  }
}