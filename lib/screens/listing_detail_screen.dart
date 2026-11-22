
import '../widgets/glass.dart';
import 'package:flutter/material.dart';
import '../core/l10n.dart';
import '../core/units.dart';
import 'agreements_screens.dart';
import 'chat_screens.dart';
import 'market_extra_screens.dart';

// BY-12, BY-13: listing detail.
// Phone number is never shown here.
class ListingDetailScreen extends StatelessWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l = app.listingById(listingId);

    context.tr('app_name'); // Subscribe to language.

    if (l == null) {
      return const Scaffold(
        body: Center(child: Text('—')),
      );
    }

    final kg = l.kg;

    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              k,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );

    return FloatingScaffold(
      appBar: AppBar(
        title: Text('${l.crop} · ${l.variety}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PhotoGalleryScreen(),
              ),
            ),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.photo_camera_back,
                  size: 56,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          row(
            context.tr('quantity'),
            '${fmtNum(l.quantity)} ${context.tr(l.unit.key)}',
          ),

          if (l.unit != QtyUnit.kg)
            row(
              context.tr('unit_kg'),
              kg == null
                  ? '—'
                  : '≈ ${fmtNum(kg)} ${context.tr('unit_kg')}',
            ),

          row(context.tr('grade'), l.grade),

          row(
            context.tr('village'),
            '${l.village}, ${l.district}',
          ),

          row(
            context.tr('ready_date'),
            fmtDate(l.readyDate),
          ),

          row(
            context.tr('expected_price'),
            '₹${fmtNum(l.expectedPrice)} ${context.tr('per')} ${context.tr(l.unit.key)}',
          ),

          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FarmerProfileScreen(),
              ),
            ),
            child: row(
              context.tr('farmer'),
              '${l.farmerFirstName}  ›',
            ),
          ),

          const SizedBox(height: 8),

          GlassCard(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text(context.tr('phone_hidden')),
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            icon: const Icon(Icons.chat),
            label: Text(context.tr('chat_farmer')),
            onPressed: () async {
              try {
                final chat = await app.startChat(l);

                if (!context.mounted) return;

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chat.id,
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            icon: const Icon(Icons.handshake),
            label: Text(context.tr('propose_deal')),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AgreementFormScreen(
                  listingId: l.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
