// lib/features/admin_platform/customer_management/market_explorer/tabs/list_tab/dialogs/list_tab_dialogs.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/zaecdcenters_model.dart';
import '../../../controllers/market_explorer_controller.dart';
import '../../../../sales_pipeline/controllers/sales_pipeline_controller.dart';
import '../../../../../../../utils/app_logger.dart';

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

  static void showAddToPipelineDialog(ZAECDCenters prospect) {
    AppLogger.d('Opening Add to Pipeline dialog for: ${prospect.ecdName}');

    final expectedCloseDateController = TextEditingController();
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 60));
    expectedCloseDateController.text = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    final RxList<String> selectedTags = <String>[].obs;
    final availableTags = ['Hot Lead', 'Demo Ready', 'Budget Confirmed', 'Decision Maker', 'Urgent'];

    Get.dialog(
      AlertDialog(
        title: Text('Add ${prospect.ecdName} to Pipeline'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will create a new deal in the sales pipeline',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Deal value section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deal Value',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Monthly:'),
                            Text(
                              'R${(prospect.numberOfChildren * 9.20).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Annual:'),
                            Text(
                              'R${(prospect.numberOfChildren * 9.20 * 12).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Expected close date
                  TextField(
                    controller: expectedCloseDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Expected Close Date',
                      hintText: 'Select expected close date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 60)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF875DEC),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                          expectedCloseDateController.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tags selection
                  const Text(
                    'Tags (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTags.map((tag) {
                      return Obx(() => FilterChip(
                        label: Text(tag),
                        selected: selectedTags.contains(tag),
                        onSelected: (selected) {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        },
                        selectedColor: const Color(0xFF875DEC).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF875DEC),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: selectedTags.contains(tag)
                              ? const Color(0xFF875DEC)
                              : Colors.grey[700],
                        ),
                      ));
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Initial stage info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Deal will be created in "Initial Contact" stage',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.d('User cancelled Add to Pipeline');
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              AppLogger.d('User confirmed Add to Pipeline');

              try {
                Get.back(); // Close dialog first

                // Initialize controllers with guaranteed non-null values
                final SalesPipelineController pipelineController;
                final MarketExplorerController marketController;

                // Ensure SalesPipelineController exists
                try {
                  if (Get.isRegistered<SalesPipelineController>()) {
                    AppLogger.d('SalesPipelineController already registered');
                    pipelineController = Get.find<SalesPipelineController>();
                  } else {
                    AppLogger.d('SalesPipelineController not registered, creating new instance');
                    pipelineController = Get.put(SalesPipelineController());
                    // Give it a moment to initialize
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                } catch (e) {
                  AppLogger.e('Failed to initialize SalesPipelineController: $e');
                  throw Exception('Failed to initialize Sales Pipeline controller');
                }

                // Ensure MarketExplorerController exists
                try {
                  if (Get.isRegistered<MarketExplorerController>()) {
                    AppLogger.d('MarketExplorerController already registered');
                    marketController = Get.find<MarketExplorerController>();
                  } else {
                    AppLogger.w('MarketExplorerController not registered, creating new instance');
                    marketController = Get.put(MarketExplorerController());
                    // Give it a moment to initialize
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                } catch (e) {
                  AppLogger.e('Failed to initialize MarketExplorerController: $e');
                  throw Exception('Failed to initialize Market Explorer controller');
                }

                AppLogger.d('Controllers initialized successfully');
                AppLogger.d('Creating deal for center: ${prospect.id}');
                AppLogger.d('Center name: ${prospect.ecdName}');
                AppLogger.d('Expected close date: ${selectedDate?.toIso8601String()}');
                AppLogger.d('Tags: ${selectedTags.join(', ')}');

                // Call the pipeline controller to create the deal
                bool success = false;
                try {
                  success = await pipelineController.createDeal(
                    prospect,
                    initialStage: 'Initial Contact',
                    expectedCloseDate: selectedDate,
                    tags: selectedTags.toList(),
                  );
                  AppLogger.d('CreateDeal returned: $success');
                } catch (e) {
                  AppLogger.e('Error calling createDeal: $e');
                  throw Exception('Failed to create deal: $e');
                }

                if (success) {
                  AppLogger.d('Deal created successfully');

                  // Only add a note, don't update pipeline status again
                  // as the deal creation already sets the pipeline status
                  try {
                    final noteAdded = await marketController.addNote(
                      prospect.id,
                      'Deal created and added to sales pipeline',
                      'pipeline',
                    );
                    AppLogger.d('Note added: $noteAdded');
                  } catch (e) {
                    AppLogger.e('Error adding note: $e');
                    // Don't fail the whole operation if this fails
                  }

                  // Note: Market Explorer data will refresh when user navigates back

                  // Success notification already shown by createDeal
                  // Optionally navigate to pipeline view
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Deal Created'),
                      content: const Text('Would you like to view the deal in the pipeline?'),
                      actions: [
                        TextButton(
                          onPressed: Get.back,
                          child: const Text('Stay Here'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.toNamed('/admin/customers/sales-pipeline');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF875DEC),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('View Pipeline'),
                        ),
                      ],
                    ),
                  );
                } else {
                  AppLogger.e('Failed to create deal - createDeal returned false');
                  // Error notification already shown by createDeal
                }
              } catch (e, stackTrace) {
                AppLogger.e('Error in Add to Pipeline: $e', e, stackTrace);
                Get.snackbar(
                  'Error',
                  'An error occurred: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 5),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add to Pipeline'),
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
      case 'add_to_pipeline':
        showAddToPipelineDialog(prospect);
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