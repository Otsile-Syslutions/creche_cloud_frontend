// lib/features/admin_platform/customer_management/market_explorer/tabs/map_tab/dialogs/territory_dialogs.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TerritoryDialogs {

  static void showCreateTerritoryDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Create New Territory'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Territory Name',
                  hintText: 'Enter territory name',
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Province',
                  hintText: 'Select province',
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Assigned Representative',
                  hintText: 'Select sales representative',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Draw territory boundaries on the map',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Territory created successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  static void showExportTerritoriesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Territories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select export format for territory data:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Export as CSV'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Territory data exported as CSV',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Export as KML'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Territory data exported as KML',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as GeoJSON'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Territory data exported as GeoJSON',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static void showEditTerritoryDialog(String territoryName) {
    Get.dialog(
      AlertDialog(
        title: Text('Edit Territory: $territoryName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Territory Name',
                  hintText: territoryName,
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Assigned Representative',
                  hintText: 'Change sales representative',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Adjust territory boundaries on the map',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showDeleteTerritoryConfirmation(territoryName);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Territory'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Territory updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  static void _showDeleteTerritoryConfirmation(String territoryName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Territory'),
        content: Text(
          'Are you sure you want to delete the territory "$territoryName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Deleted',
                'Territory deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}