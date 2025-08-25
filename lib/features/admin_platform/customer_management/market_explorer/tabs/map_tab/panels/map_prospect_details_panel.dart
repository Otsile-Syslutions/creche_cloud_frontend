// lib/features/admin_platform/customer_management/market_explorer/tabs/map_tab/panels/prospect_details_panel.dart

import 'package:flutter/material.dart';
import '../../../models/zaecdcenters_model.dart';

class ProspectDetailsPanel extends StatelessWidget {
  final ZAECDCenters prospect;
  final VoidCallback onClose;
  final Function(ZAECDCenters) onViewDetails;

  const ProspectDetailsPanel({
    super.key,
    required this.prospect,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prospect.ecdName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onClose,
                ),
              ],
            ),
            const Divider(),
            Text('${prospect.numberOfChildren} children'),
            Text('Score: ${prospect.leadScore}'),
            Text('Status: ${prospect.registrationStatus}'),
            if (prospect.contactPerson != null)
              Text('Contact: ${prospect.contactPerson}'),
            if (prospect.telephone != null)
              Text('Phone: ${prospect.telephone}'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              onPressed: () => onViewDetails(prospect),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF875DEC),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}