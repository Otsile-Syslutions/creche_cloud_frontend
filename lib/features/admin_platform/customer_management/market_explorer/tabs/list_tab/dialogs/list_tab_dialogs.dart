// lib/features/admin_platform/customer_management/market_explorer/tabs/list_tab/dialogs/list_tab_dialogs.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/zaecdcenters_model.dart';
import '../../../controllers/market_explorer_controller.dart';

class ListTabDialogs {

  // ============== PROSPECT MANAGEMENT DIALOGS ==============

  static void showAddProspectDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add New ECD Prospect'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(
                  labelText: 'ECD Name',
                  hintText: 'Enter ECD center name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contact Person',
                  hintText: 'Enter contact person name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                ),
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
                'New prospect added successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static void showAddToCampaignDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Add ${prospect.ecdName} to Campaign'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Campaign',
                hintText: 'Select campaign',
              ),
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
                'Success',
                '${prospect.ecdName} added to campaign',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static void showScheduleDemoDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Schedule Demo for ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select date',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: 'Select time',
              ),
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
                'Success',
                'Demo scheduled for ${prospect.ecdName}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  // ============== BULK OPERATIONS DIALOGS ==============

  static void showAssignRepDialog(MarketExplorerController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Assign Sales Representative'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a sales rep for ${controller.selectedCenters.length} centers'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Sales Rep',
                hintText: 'Select sales representative',
              ),
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
                'Success',
                'Sales rep assigned to ${controller.selectedCenters.length} centers',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  static void showBulkUpdateDialog(MarketExplorerController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Bulk Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update ${controller.selectedCenters.length} centers'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Lead Status',
                hintText: 'Select new lead status',
              ),
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
                'Success',
                'Updated ${controller.selectedCenters.length} centers',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static void showBulkEnrichDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bulk Enrich Contact Data'),
        content: const Text('This feature will enrich contact information for selected centers.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Processing',
                'Enriching contact data for selected centers...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Enrichment'),
          ),
        ],
      ),
    );
  }

  // ============== DATA MANAGEMENT DIALOGS ==============

  static void showExportDialog(MarketExplorerController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Export as CSV'),
              onTap: () {
                controller.exportData('csv');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              onTap: () {
                controller.exportData('json');
                Get.back();
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

  static void showImportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Import ECD Center Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a CSV file to import additional ECD center data.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose File'),
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
                'Processing',
                'Importing ECD center data...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  // ============== CRM ACTIVITY DIALOGS ==============

  static void showAddNoteDialog(ZAECDCenters prospect) {
    final noteController = TextEditingController();
    final controller = Get.find<MarketExplorerController>();

    Get.dialog(
      AlertDialog(
        title: Text('Add Note for ${prospect.ecdName}'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                controller.addNote(prospect.id, noteController.text, 'general');
                Get.back();
                Get.snackbar(
                  'Success',
                  'Note added successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  static void showTaskDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Create Task for ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Due Date',
                hintText: 'Select due date',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
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
                'Success',
                'Task created successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }

  static void showMeetingDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Schedule Meeting with ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Meeting Title',
                hintText: 'Enter meeting title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date & Time',
                hintText: 'Select date and time',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Location/Link',
                hintText: 'Enter location or meeting link',
              ),
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
                'Success',
                'Meeting scheduled successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  static void showLogActivityDialog(ZAECDCenters prospect, String activityType) {
    Get.dialog(
      AlertDialog(
        title: Text('Log $activityType for ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '$activityType Details',
                hintText: 'Enter details about the $activityType',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date & Time',
                hintText: 'When did this occur?',
              ),
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
                'Success',
                '$activityType logged successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Activity'),
          ),
        ],
      ),
    );
  }

  // ============== QUICK ACTIONS ==============

  static void callProspect(ZAECDCenters prospect) {
    Get.snackbar(
      'Call',
      'Calling ${prospect.contactPerson ?? prospect.ecdName} at ${prospect.telephone}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF875DEC),
      colorText: Colors.white,
    );
  }

  static void emailProspect(ZAECDCenters prospect) {
    Get.snackbar(
      'Email',
      'Opening email composer for ${prospect.ecdName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF875DEC),
      colorText: Colors.white,
    );
  }

  // ============== ACTION HANDLERS ==============

  static void handleProspectAction(ZAECDCenters prospect, String action, MarketExplorerController controller) async {
    switch (action) {
      case 'add_to_campaign':
        showAddToCampaignDialog(prospect);
        break;
      case 'schedule_demo':
        showScheduleDemoDialog(prospect);
        break;
      case 'mark_contacted':
        await controller.updateLeadStatus(
          prospect.id,
          'Contacted',
          prospect.pipelineStage,
        );
        break;
    }
  }

  static void handleCRMAction(ZAECDCenters prospect, String action) {
    switch (action) {
      case 'log_sms':
        showLogActivityDialog(prospect, 'SMS');
        break;
      case 'log_whatsapp':
        showLogActivityDialog(prospect, 'WhatsApp');
        break;
      case 'log_linkedin':
        showLogActivityDialog(prospect, 'LinkedIn');
        break;
      case 'log_activity':
        showLogActivityDialog(prospect, 'Activity');
        break;
    }
  }
}