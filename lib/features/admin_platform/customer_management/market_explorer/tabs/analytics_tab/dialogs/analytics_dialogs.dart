// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab/dialogs/analytics_dialogs.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsDialogs {

  static void showExportAnalyticsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Analytics Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select format for analytics export:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Export as CSV'),
              subtitle: const Text('Tabular data for spreadsheets'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Analytics data exported as CSV',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF Report'),
              subtitle: const Text('Formatted report with charts'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Generating',
                  'PDF report is being generated',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              subtitle: const Text('Raw data for integration'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Exporting',
                  'Analytics data exported as JSON',
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

  static void showProjectionSettingsDialog() {
    final conservativeGrowthController = TextEditingController(text: '10');
    final aggressiveGrowthController = TextEditingController(text: '25');
    final timeHorizonController = TextEditingController(text: '5');

    Get.dialog(
      AlertDialog(
        title: const Text('Growth Projection Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: conservativeGrowthController,
                decoration: const InputDecoration(
                  labelText: 'Conservative Growth Rate (%)',
                  hintText: 'Annual growth percentage',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aggressiveGrowthController,
                decoration: const InputDecoration(
                  labelText: 'Aggressive Growth Rate (%)',
                  hintText: 'Annual growth percentage',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeHorizonController,
                decoration: const InputDecoration(
                  labelText: 'Time Horizon',
                  hintText: 'Number of years',
                  suffixText: 'years',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Additional Factors',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Include seasonal variations'),
                value: true,
                onChanged: (value) {},
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Account for market saturation'),
                value: false,
                onChanged: (value) {},
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Include competitive factors'),
                value: true,
                onChanged: (value) {},
                dense: true,
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
                'Updated',
                'Projection settings updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply Settings'),
          ),
        ],
      ),
    );
  }

  static void showFilterAnalyticsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Analytics Data'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Time Period'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '3M', label: Text('3M')),
                  ButtonSegment(value: '6M', label: Text('6M')),
                  ButtonSegment(value: '1Y', label: Text('1Y')),
                  ButtonSegment(value: 'ALL', label: Text('All')),
                ],
                selected: const {'1Y'},
                onSelectionChanged: (Set<String> selection) {},
              ),
              const SizedBox(height: 16),
              const Text('Provinces'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['GT', 'KZN', 'WC', 'EC', 'LIM', 'MP', 'NW', 'FS', 'NC']
                    .map((province) => FilterChip(
                  label: Text(province),
                  selected: false,
                  onSelected: (selected) {},
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Registration Status'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'Fully registered',
                  'Conditionally registered',
                  'In process',
                  'Not registered'
                ].map((status) => FilterChip(
                  label: Text(status),
                  selected: false,
                  onSelected: (selected) {},
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Applied',
                'Analytics filters applied',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  static void showShareAnalyticsDialog() {
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Share Analytics Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Recipients',
                hintText: 'Enter email addresses',
                helperText: 'Separate multiple emails with commas',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Include in Report:'),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Market Penetration'),
              value: true,
              onChanged: (value) {},
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Provincial Analysis'),
              value: true,
              onChanged: (value) {},
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Growth Projections'),
              value: true,
              onChanged: (value) {},
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Opportunity Mapping'),
              value: false,
              onChanged: (value) {},
              dense: true,
            ),
            const SizedBox(height: 16),
            const Text('Report Format:'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PDF', label: Text('PDF')),
                ButtonSegment(value: 'Excel', label: Text('Excel')),
                ButtonSegment(value: 'Email', label: Text('Email')),
              ],
              selected: const {'PDF'},
              onSelectionChanged: (Set<String> selection) {},
            ),
          ],
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
                'Sent',
                'Analytics report sent successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }

  static void showComparePeriodsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Compare Time Periods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Period 1'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Start Date',
                hintText: 'Select start date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {
                // Show date picker
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'End Date',
                hintText: 'Select end date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {
                // Show date picker
              },
            ),
            const SizedBox(height: 16),
            const Text('Period 2'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Start Date',
                hintText: 'Select start date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {
                // Show date picker
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'End Date',
                hintText: 'Select end date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {
                // Show date picker
              },
            ),
          ],
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
                'Comparing',
                'Generating comparison report',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Compare'),
          ),
        ],
      ),
    );
  }
}