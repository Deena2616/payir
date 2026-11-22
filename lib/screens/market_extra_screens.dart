
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/units.dart';
import '../core/l10n.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/glass.dart';
import 'shared_bits.dart';
import 'listing_detail_screen.dart';

// Farmer public profile. First name only, no phone number (BY-12). UI only.
class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  Widget _stat(String v, String l) => Expanded(
    child: GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              v,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
            Text(
              l,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: const Text('Farmer')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: kGreen,
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Murugan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
          ),
          const Center(child: Text('Papanasam, Thanjavur')),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('3', 'Live listings'),
              _stat('12', 'Deals done'),
              _stat('2024', 'Member since'),
            ],
          ),
          GlassCard(
            color: Colors.blue.shade50,
            child: const ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text(
                'Phone number is hidden. Use chat to talk to the farmer.',
              ),
            ),
          ),
          const SectionLabel('Other listings by this farmer'),
          for (final t in const [
            ['Paddy · ADT 45', '120 bag · Ready 19-11-2026'],
            ['Groundnut · TMV 7', '450 kg · Ready 18-11-2026'],
          ])
            GlassCard(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.grass),
                ),
                title: Text(
                  t[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(t[1]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat),
            label: const Text('Chat with farmer'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Report this farmer'),
          ),
        ],
      ),
    );
  }
}

// Full-screen swipe gallery of listing photos. UI only (placeholders).
class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  int _page = 0;

  static const _caps = [
    'Stock in godown',
    'Grain close-up',
    'Bags stacked',
    'Field',
  ];

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(
        title: Text('Photos ${_page + 1}/${_caps.length}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: _caps.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFC8E6C9),
                        Color(0xFF80CBC4),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_camera_back,
                        size: 80,
                        color: kGreen,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _caps[i],
                        style: const TextStyle(
                          fontSize: 16,
                          color: kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _caps.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  width: i == _page ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? kGreen : Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Saved listings. Connected to MySQL.
class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  @override
  void initState() {
    super.initState();

    // Load saved listings from the database when this screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadSavedListings();
      }
    });
  }

  Future<void> _removeListing(Listing listing) async {
    try {
      await context.read<AppState>().removeSavedListing(listing.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing removed from saved items'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove listing: $e'),
        ),
      );
    }
  }

  Widget _savedListingCard(Listing listing) {
    final kg = listing.kg;

    return GlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        leading: const CircleAvatar(
          child: Icon(Icons.grass),
        ),
        title: Text(
          '${listing.crop} · ${listing.variety}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: kInk,
          ),
        ),
        subtitle: Text(
          '${fmtNum(listing.quantity)} ${context.tr(listing.unit.key)}'
              '${kg != null && listing.unit != QtyUnit.kg ? ' (≈ ${fmtNum(kg)} kg)' : ''}'
              '\n${listing.village}, ${listing.district}'
              '\nGrade ${listing.grade} · Ready ${fmtDate(listing.readyDate)}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Remove saved listing',
          icon: const Icon(
            Icons.bookmark,
            color: kGreen,
          ),
          onPressed: () => _removeListing(listing),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(
                listingId: listing.id,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return FloatingScaffold(
      appBar: AppBar(
        title: const Text('Saved listings'),
        actions: [
          IconButton(
            tooltip: 'Refresh saved listings',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              s.loadSavedListings();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (s.isLoadingSavedListings && s.savedListings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (s.savedListingsError != null &&
              s.savedListings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.savedListingsError!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => s.loadSavedListings(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (s.savedListings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No saved listings yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the bookmark icon on a listing to save it here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: s.loadSavedListings,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    bottom: 10,
                  ),
                  child: Text(
                    '${s.savedListings.length} saved listing(s)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: kInk,
                    ),
                  ),
                ),
                for (final listing in s.savedListings)
                  _savedListingCard(listing),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Phase 2: one posted requirement with farmer responses. UI only.
class RequirementDetailScreen extends StatelessWidget {
  const RequirementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: const Text('Requirement')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Paddy · 10 tonne',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ),
                      const StatusPill('Open', Colors.green),
                    ],
                  ),
                  const Divider(height: 24),
                  const InfoRow('District', 'Thanjavur'),
                  const InfoRow('Needed by', '30-11-2026'),
                  const InfoRow('Posted on', '16-11-2026'),
                  const InfoRow(
                    'Notes',
                    'ADT 45 preferred, moisture below 14%.',
                  ),
                ],
              ),
            ),
          ),
          const SectionLabel('Farmer responses (2)'),
          for (final r in const [
            ['Murugan', 'Papanasam · 8 tonne · ₹22,000 per tonne'],
            ['Priya', 'Orathanadu · 10 tonne · ₹22,400 per tonne'],
          ])
            GlassCard(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(r[0][0]),
                ),
                title: Text(
                  r[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(r[1]),
                trailing: const Icon(Icons.chat_bubble_outline),
                onTap: () {},
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
