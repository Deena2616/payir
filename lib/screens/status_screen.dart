
import '../widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/l10n.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'common.dart';
import 'registration_screen.dart';

// BY-07 / BY-08: Shows Pending / Returned / Rejected / Suspended.
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final st = s.status;

    final icon = switch (st) {
      BuyerStatus.returned => Icons.assignment_return,
      BuyerStatus.rejected || BuyerStatus.suspended => Icons.block,
      _ => Icons.hourglass_top,
    };

    return FloatingScaffold(
      appBar: AppBar(
        title: Text(context.tr('app_name')),
        actions: [
          const LangSwitch(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.tr('logout'),
            onPressed: s.logout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            icon,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),

          Center(
            child: Chip(
              label: Text(
                '${context.tr('status')}: '
                    '${context.tr('status_${st.name}')}',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pending status and refresh button
          if (st == BuyerStatus.pending) ...[
            Text(
              context.tr('buyer_pending'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: s.refreshBuyerStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
          ],

          // Returned status
          if (st == BuyerStatus.returned) ...[
            Text(
              '${context.tr('return_reason')}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(s.returnReason),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const RegistrationScreen(editing: true),
                  ),
                );
              },
              child: Text(context.tr('update_docs')),
            ),
          ],

          const SizedBox(height: 16),

          GlassCard(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: Text(context.tr('locked_note')),
            ),
          ),
        ],
      ),
    );
  }
}
