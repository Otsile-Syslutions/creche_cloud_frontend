// lib/features/admin_platform/customer_management/market_explorer/tabs/list_tab/panels/list_detail_panel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/zaecdcenters_model.dart';
import '../dialogs/list_tab_dialogs.dart';

class ListDetailPanel extends StatelessWidget {
  final ZAECDCenters prospect;

  const ListDetailPanel({super.key, required this.prospect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _toCamelCase(prospect.ecdName),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatusChip(prospect.registrationStatus),
                                const SizedBox(width: 12),
                                Text(
                                  'Score: ${prospect.leadScore}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(prospect.leadScore),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (prospect.isMovedToPipeline)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'In Pipeline',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.green[700],
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Add to Pipeline button
                      if (!prospect.isMovedToPipeline)
                        ElevatedButton.icon(
                          onPressed: () => ListTabDialogs.showAddToPipelineDialog(prospect),
                          icon: const Icon(Icons.trending_up, size: 18),
                          label: const Text('Add to Pipeline'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF875DEC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed('/admin/customers/sales-pipeline');
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View in Pipeline'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // CRM Actions bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  _buildCRMActionButton(Icons.email_outlined, 'Email', () => ListTabDialogs.emailProspect(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.phone_outlined, 'Call', () => ListTabDialogs.callProspect(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.note_add_outlined, 'Note', () => ListTabDialogs.showAddNoteDialog(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.task_outlined, 'Task', () => ListTabDialogs.showTaskDialog(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.event_outlined, 'Meeting', () => ListTabDialogs.showMeetingDialog(prospect)),
                  const SizedBox(width: 16),
                  // More menu for additional actions
                  PopupMenuButton<String>(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.more_horiz, size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          const Text(
                            'More',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    onSelected: (value) => ListTabDialogs.handleCRMAction(prospect, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'log_sms', child: Text('Log SMS')),
                      const PopupMenuItem(value: 'log_whatsapp', child: Text('Log WhatsApp')),
                      const PopupMenuItem(value: 'log_linkedin', child: Text('Log LinkedIn Message')),
                      const PopupMenuItem(value: 'log_activity', child: Text('Log Activity')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Activities
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Recent Activities'),
                        _buildActivityTimeline(prospect),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Upcoming Tasks'),
                        _buildUpcomingTasks(prospect),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right column - School info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('About this School'),
                        _buildSchoolInfo(prospect),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Contacts'),
                        _buildContactsSection(prospect),
                        if (prospect.pipelineStatus.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Pipeline History'),
                          _buildPipelineHistory(prospect),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCRMActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(ZAECDCenters prospect) {
    final notes = prospect.notes;
    if (notes != null && notes.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notes.take(5).map((note) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getActivityIcon(note.type),
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.content,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(note.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Text(
        'No recent activities',
        style: TextStyle(
          color: Colors.grey,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildUpcomingTasks(ZAECDCenters prospect) {
    final tasks = prospect.tasks;
    if (tasks != null && tasks.isNotEmpty) {
      final upcomingTasks = tasks
          .where((task) => !task.completed && task.dueDate != null)
          .take(3)
          .toList();

      if (upcomingTasks.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: upcomingTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          Text(
                            'Due: ${_formatDate(task.dueDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey[500],
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Text(
        'No upcoming tasks',
        style: TextStyle(
          color: Colors.grey,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildSchoolInfo(ZAECDCenters prospect) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Province', prospect.province),
          _buildInfoRow('City', prospect.townCity ?? 'N/A'),
          _buildInfoRow('Children', prospect.numberOfChildren.toString()),
          _buildInfoRow('Registration', prospect.registrationStatus),
          _buildInfoRow('Lead Status', prospect.leadStatus),
          _buildInfoRow('Pipeline Stage', prospect.pipelineStage),
          if (prospect.streetAddress != null)
            _buildInfoRow('Address', prospect.streetAddress!),
          if (prospect.potentialMRR > 0)
            _buildInfoRow('Potential MRR', 'R${prospect.potentialMRR.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildContactsSection(ZAECDCenters prospect) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prospect.contactPerson != null && prospect.contactPerson!.isNotEmpty)
            _buildContactCard(prospect.contactPerson!, prospect.telephone, prospect.email),
          if (prospect.contactPerson == null || prospect.contactPerson!.isEmpty)
            const Text(
              'No contacts available',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPipelineHistory(ZAECDCenters prospect) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: prospect.pipelineStatus.map((status) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getPipelineStatusColor(status.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.status,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      if (status.notes != null && status.notes!.isNotEmpty)
                        Text(
                          status.notes!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto',
                          ),
                        ),
                      Text(
                        _formatDate(status.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(String name, String? phone, String? email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _toCamelCase(name),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 4),
        if (phone != null && phone.isNotEmpty)
          Text(
            phone,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
        if (email != null && email.isNotEmpty)
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Fully registered':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        break;
      case 'Conditionally registered':
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        break;
      case 'In process':
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.grey;
  }

  Color _getPipelineStatusColor(String status) {
    switch (status) {
      case 'Initial Contact':
        return Colors.blue;
      case 'Demo Scheduled':
        return Colors.orange;
      case 'Demo Completed':
        return Colors.purple;
      case 'Proposal Sent':
        return Colors.indigo;
      case 'Nurturing':
        return Colors.amber;
      case 'Onboarding':
        return Colors.green;
      case 'Closed Won':
        return Colors.green[700]!;
      case 'Closed Lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'call':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'meeting':
        return Icons.people;
      case 'demo':
        return Icons.play_circle_outline;
      case 'task':
        return Icons.task_alt;
      default:
        return Icons.note;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}