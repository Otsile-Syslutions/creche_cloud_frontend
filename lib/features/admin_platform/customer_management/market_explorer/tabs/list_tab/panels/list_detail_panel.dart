// lib/features/admin_platform/customer_management/market_explorer/widgets/list_detail_panel.dart

import 'package:flutter/material.dart';

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
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Schedule Demo button
                      ElevatedButton.icon(
                        onPressed: () => ListTabDialogs.showScheduleDemoDialog(prospect),
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: const Text('Schedule Demo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF875DEC),
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
    // This would be populated with actual activity data
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
          if (prospect.streetAddress != null)
            _buildInfoRow('Address', prospect.streetAddress!),
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

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}