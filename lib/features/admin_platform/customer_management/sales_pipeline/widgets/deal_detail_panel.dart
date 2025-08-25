// lib/features/admin_platform/customer_management/sales_pipeline/widgets/deal_detail_panel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/deal_model.dart';
import '../controllers/sales_pipeline_controller.dart';

class DealDetailPanel extends StatefulWidget {
  final Deal deal;
  final VoidCallback onClose;

  const DealDetailPanel({
    super.key,
    required this.deal,
    required this.onClose,
  });

  @override
  State<DealDetailPanel> createState() => _DealDetailPanelState();
}

class _DealDetailPanelState extends State<DealDetailPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final controller = Get.find<SalesPipelineController>();

  int _selectedTab = 0;
  final _notesController = TextEditingController();
  final _activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Deal info summary
            _buildDealSummary(),

            // Tabs
            _buildTabs(),

            // Tab content
            Expanded(
              child: _buildTabContent(),
            ),

            // Actions footer
            _buildActionsFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.deal.stageColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.deal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.deal.ecdCenter?.ecdName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _animationController.reverse();
              widget.onClose();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDealSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Value', 'R${widget.deal.value.annual.toStringAsFixed(0)}'),
              _buildSummaryItem('Probability', '${widget.deal.probability.toStringAsFixed(0)}%'),
              _buildSummaryItem('Weighted', 'R${widget.deal.value.weighted.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Stage', widget.deal.stage),
              _buildSummaryItem(
                'Expected Close',
                widget.deal.expectedCloseDate != null
                    ? '${widget.deal.expectedCloseDate!.day}/${widget.deal.expectedCloseDate!.month}/${widget.deal.expectedCloseDate!.year}'
                    : 'Not set',
              ),
            ],
          ),
          if (widget.deal.isHot || widget.deal.isRotting) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.deal.isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'HOT DEAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.deal.isRotting) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'ROTTING (${widget.deal.daysInStage} days)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Details', 0, Icons.info_outline),
          _buildTab('Activities', 1, Icons.event),
          _buildTab('Notes', 2, Icons.note),
          _buildTab('History', 3, Icons.history),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
              bottom: BorderSide(
                color: const Color(0xFF875DEC),
                width: 2,
              ),
            )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF875DEC) : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF875DEC) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildDetailsTab();
      case 1:
        return _buildActivitiesTab();
      case 2:
        return _buildNotesTab();
      case 3:
        return _buildHistoryTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Contact Information'),
          if (widget.deal.contacts.isNotEmpty) ...[
            ...widget.deal.contacts.map((contact) => _buildContactCard(contact)),
          ] else
            Text(
              'No contacts added',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),

          const SizedBox(height: 20),
          _buildSection('Deal Information'),
          _buildDetailRow('Owner', widget.deal.owner?.fullName ?? 'Unassigned'),
          _buildDetailRow('Source', widget.deal.source),
          _buildDetailRow('Created', _formatDate(widget.deal.createdAt)),
          _buildDetailRow('Days in Pipeline', '${widget.deal.daysInPipeline}'),

          const SizedBox(height: 20),
          _buildSection('Organization Details'),
          if (widget.deal.ecdCenter != null) ...[
            _buildDetailRow('Province', widget.deal.ecdCenter!.province),
            _buildDetailRow('City', widget.deal.ecdCenter!.townCity ?? 'N/A'),
            _buildDetailRow('Children', '${widget.deal.ecdCenter!.numberOfChildren}'),
            _buildDetailRow('Registration', widget.deal.ecdCenter!.registrationStatus),
          ],

          if (widget.deal.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSection('Tags'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.deal.tags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey.shade100,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final upcomingActivities = widget.deal.activities
        .where((a) => !a.completed)
        .toList()
      ..sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));

    final completedActivities = widget.deal.activities
        .where((a) => a.completed)
        .toList()
      ..sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

    return Column(
      children: [
        // Add activity input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _activityController,
                  decoration: const InputDecoration(
                    hintText: 'Add activity...',
                    hintStyle: TextStyle(fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF875DEC)),
                onPressed: _addActivity,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcomingActivities.isNotEmpty) ...[
                _buildSection('Upcoming'),
                ...upcomingActivities.map((activity) => _buildActivityCard(activity)),
              ],

              if (completedActivities.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSection('Completed'),
                ...completedActivities.map((activity) => _buildActivityCard(activity)),
              ],

              if (widget.deal.activities.isEmpty)
                Center(
                  child: Text(
                    'No activities yet',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        // Add note input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: TextStyle(fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF875DEC)),
                onPressed: _addNote,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.deal.notes.length,
            itemBuilder: (context, index) {
              final note = widget.deal.notes[widget.deal.notes.length - 1 - index];
              return _buildNoteCard(note);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Stage History'),
        Text(
          'Stage progression history will be shown here',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionsFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          if (!widget.deal.isClosed) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _markAsWon(),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Won'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _markAsLost(),
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Lost'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ] else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _reopenDeal(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reopen Deal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF875DEC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(DealContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (contact.isPrimary)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRIMARY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
            if (contact.role != null) ...[
              const SizedBox(height: 4),
              Text(
                contact.role!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (contact.email != null || contact.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (contact.email != null) ...[
                    Icon(Icons.email, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      contact.email!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  if (contact.phone != null) ...[
                    if (contact.email != null) const SizedBox(width: 12),
                    Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      contact.phone!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(DealActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: activity.completed
              ? Colors.green.shade100
              : Colors.blue.shade100,
          child: Icon(
            _getActivityIcon(activity.type),
            size: 16,
            color: activity.completed ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          activity.subject,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            decoration: activity.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: activity.dueDate != null
            ? Text(
          _formatDate(activity.dueDate!),
          style: const TextStyle(fontSize: 11),
        )
            : null,
        trailing: activity.completed
            ? Icon(Icons.check_circle, color: Colors.green, size: 20)
            : IconButton(
          icon: const Icon(Icons.check_circle_outline, size: 20),
          onPressed: () => _completeActivity(activity),
        ),
      ),
    );
  }

  Widget _buildNoteCard(DealNote note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  note.author?.fullName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(note.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (note.isPinned) ...[
                  const Spacer(),
                  Icon(Icons.push_pin, size: 14, color: Colors.orange),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              note.content,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays.abs();

    if (difference == 0) return 'Today';
    if (difference == 1) return date.isBefore(now) ? 'Yesterday' : 'Tomorrow';
    if (difference < 7) return '$difference days ${date.isBefore(now) ? "ago" : "from now"}';

    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _addActivity() {
    if (_activityController.text.isNotEmpty) {
      controller.addActivity(
        widget.deal.id,
        ActivityData(
          type: 'task',
          subject: _activityController.text,
          dueDate: DateTime.now().add(const Duration(days: 1)),
        ),
      );
      _activityController.clear();
    }
  }

  void _addNote() {
    if (_notesController.text.isNotEmpty) {
      // Add note logic
      _notesController.clear();
    }
  }

  void _completeActivity(DealActivity activity) {
    // Complete activity logic
  }

  void _markAsWon() {
    controller.closeDealWon(
      widget.deal.id,
      WonDetails(
        finalPrice: widget.deal.value.annual,
        keyFactors: ['Good fit'],
      ),
    );
    widget.onClose();
  }

  void _markAsLost() {
    controller.closeDealLost(
      widget.deal.id,
      LostReason(
        primary: 'Price',
        details: 'Budget constraints',
      ),
    );
    widget.onClose();
  }

  void _reopenDeal() {
    controller.updateDealStage(widget.deal.id, 'Initial Contact');
    widget.onClose();
  }
}