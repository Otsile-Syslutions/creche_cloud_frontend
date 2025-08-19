// lib/main.dart - Update your main.dart file with these changes

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/global_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app logger
  AppLogger.i('Starting Creche Cloud application...');

  // Initialize global bindings
  GlobalBindings().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Creche Cloud',
      debugShowCheckedModeBanner: false,

      // Use GlobalBindings as initial binding
      initialBinding: GlobalBindings(),

      // Routes
      initialRoute: AppRoutes.initial,
      getPages: AppPages.pages,

      // Unknown route fallback
      unknownRoute: GetPage(
        name: '/404',
        page: () => const NotFoundView(),
      ),

      // Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Error handling
      builder: (context, widget) {
        // Ensure dependencies are always available
        if (!DependencyManager.checkDependencies()) {
          AppLogger.w('Dependencies missing, ensuring they exist...');
          DependencyManager.ensureCoreServices();
        }

        return widget ?? const SizedBox.shrink();
      },
    );
  }
}

// 404 Not Found view
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.initial),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}