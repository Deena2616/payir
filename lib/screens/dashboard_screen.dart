
import '../widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/l10n.dart';
import '../core/units.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../core/theme.dart';
import 'account_screens.dart';
import 'common.dart';
import 'market_extra_screens.dart';
import 'requirements_screen.dart';
import 'shared_bits.dart';
import 'support_screens.dart';
import 'listing_detail_screen.dart';
import 'notifications_screen.dart';

// BY-10, BY-11, BY-12, BY-19, SA-15 (units never mixed).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Load listings from the database when the dashboard opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadListings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = s.filteredListings;

    return FloatingScaffold(
      bottomInset: 96,
      appBar: AppBar(
        title: Text(context.tr('live_supply')),
        actions: [
          IconButton(
            icon: Badge(
              smallSize: 8,
              isLabelVisible: s.filter.active,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: context.tr('filters'),
            onPressed: () => _openFilters(context),
          ),
          _notificationMenu(context, s),
          const LangSwitch(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().loadListings(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            AnimatedEntry(child: _hero(context, s)),
            const SizedBox(height: 12),
            _cropChips(context, s),
            const SizedBox(height: 12),
            _quickActions(context),
            const SizedBox(height: 12),
            _marketPulse(context),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _stat(
                  context,
                  Icons.list_alt,
                  context.tr('live_listings'),
                  '${s.liveListings.length}',
                ),
                _stat(
                  context,
                  Icons.fiber_new,
                  context.tr('new_since_yesterday'),
                  '${s.newSinceYesterday}',
                ),
                _stat(
                  context,
                  Icons.mark_chat_unread,
                  context.tr('unread_chats'),
                  '${s.unreadChats}',
                ),
                _stat(
                  context,
                  Icons.place,
                  context.tr('districts'),
                  '${s.districtCount}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _totalsCard(context, s),
            if (s.filter.active)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: s.clearFilter,
                  icon: const Icon(Icons.clear),
                  label: Text(context.tr('clear')),
                ),
              ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    context.tr('no_listings'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            for (int i = 0; i < items.length; i++)
              AnimatedEntry(
                index: i,
                child: ListingCard(listing: items[i]),
              ),
          ],
        ),
      ),
    );
  }

  String _greeting(AppState s) {
    final h = DateTime.now().hour;

    if (s.isTamil) {
      return h < 12
          ? 'காலை வணக்கம்'
          : h < 17
          ? 'மதிய வணக்கம்'
          : 'மாலை வணக்கம்';
    }

    return h < 12
        ? 'Good morning'
        : h < 17
        ? 'Good afternoon'
        : 'Good evening';
  }

  // Horizontal crop chips: one tap filters the supply list.
  Widget _cropChips(BuildContext context, AppState s) {
    void pick(String? crop) => s.applyFilter(
      crop: crop,
      district: s.filter.district,
      minQty: s.filter.minQty,
      readyBy: s.filter.readyBy,
      unit: s.filter.unit,
    );

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s.t('any')),
              selected: s.filter.crop == null,
              onSelected: (_) => pick(null),
            ),
          ),
          for (final c in cropList)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c),
                selected: s.filter.crop == c,
                onSelected: (_) => pick(c),
              ),
            ),
        ],
      ),
    );
  }

  // Shortcut buttons to features that are otherwise a few taps away.
  Widget _quickActions(BuildContext context) {
    void open(Widget w) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => w),
      );
    }

    Widget a(IconData i, String t, Widget w) => Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => open(w),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kGreenLight, kTeal],
                  ),
                ),
                child: Icon(i, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                t,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            a(Icons.campaign, 'Post need', const PostRequirementScreen()),
            a(Icons.bookmark, 'Saved', const SavedListingsScreen()),
            a(Icons.settings, 'Settings', const SettingsScreen()),
            a(Icons.help_outline, 'Help', const HelpSupportScreen()),
          ],
        ),
      ),
    );
  }

  // Sample price trends, not database prices.
  Widget _marketPulse(BuildContext context) {
    const items = [
      ['Paddy', '₹1,750 / bag', '+2.1%', 'up'],
      ['Groundnut', '₹68 / kg', '+0.8%', 'up'],
      ['Turmeric', '₹9,200 / qtl', '-1.4%', 'down'],
      ['Maize', '₹1,400 / bag', '+0.3%', 'up'],
      ['Banana', '₹28,000 / tonne', '-0.6%', 'down'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Market pulse (sample prices)',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: kInk,
            ),
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final m in items)
                SizedBox(
                  width: 150,
                  child: GlassCard(
                    margin: const EdgeInsets.only(right: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            m[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            m[1],
                            style: const TextStyle(fontSize: 13),
                          ),
                          Row(
                            children: [
                              Icon(
                                m[3] == 'up'
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 16,
                                color: m[3] == 'up'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                m[2],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: m[3] == 'up'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Bell icon that opens a dropdown with the latest notifications.
  Widget _notificationMenu(BuildContext context, AppState s) {
    final latest = s.notifications.take(5).toList();

    return PopupMenuButton<String>(
      tooltip: s.t('notifications'),
      offset: const Offset(0, 52),
      color: const Color(0xF2FFFFFF),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: const BoxConstraints(
        minWidth: 280,
        maxWidth: 320,
      ),
      icon: Badge(
        isLabelVisible: s.unreadNotifications > 0,
        label: Text('${s.unreadNotifications}'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onOpened: s.markAllRead,
      onSelected: (v) {
        if (v == 'all') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
            ),
          );
        } else if (v == 'clear') {
          s.clearNotifications();
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
          enabled: false,
          height: 40,
          child: Text(
            s.t('notifications'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF14331A),
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        if (latest.isEmpty)
          PopupMenuItem<String>(
            enabled: false,
            child: Text(s.t('no_notifs')),
          )
        else
          for (final n in latest)
            PopupMenuItem<String>(
              value: 'item',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4, right: 10),
                    child: Icon(
                      Icons.circle,
                      size: 9,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.isTamil ? n.titleTa : n.titleEn,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          s.isTamil ? n.bodyTa : n.bodyEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fmtTime(n.time),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'all',
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.open_in_new,
                size: 18,
                color: Theme.of(ctx).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'View all',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (latest.isNotEmpty)
          const PopupMenuItem<String>(
            value: 'clear',
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.clear_all,
                  size: 20,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Clear all',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _hero(BuildContext context, AppState s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF43A047),
            Color(0xFF00897B),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x552E7D32),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting(s)}${(s.profile?.tradeName.isNotEmpty ?? false) ? ', ${s.profile!.tradeName}' : ((s.profile?.legalName.isNotEmpty ?? false) ? ', ${s.profile!.legalName}' : '')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('live_supply'),
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(
                    begin: 0,
                    end: s.liveListings.length,
                  ),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    '$v',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                Text(
                  '${context.tr('live_listings')} · ${s.districtCount} ${context.tr('districts')}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.grass,
            size: 72,
            color: Color(0x55FFFFFF),
          ),
        ],
      ),
    );
  }

  Widget _stat(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 32) / 2,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalsCard(BuildContext context, AppState s) {
    final totals = s.supplyTotals;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('remaining_by_unit'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Divider(),
            if (totals.isEmpty) const Text('—'),
            for (final t in totals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(t.crop)),
                    Text(
                      '${fmtNum(t.quantity)} ${context.tr(t.unit.key)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (t.unit != QtyUnit.kg && t.kgKnown)
                      Text(
                        '  ≈ ${fmtNum(t.kg)} ${context.tr('unit_kg')}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFilters(BuildContext context) {
    final s = context.read<AppState>();

    String? crop = s.filter.crop;
    String? district = s.filter.district;
    QtyUnit? unit = s.filter.unit;
    DateTime? readyBy = s.filter.readyBy;

    final minCtl = TextEditingController(
      text: s.filter.minQty?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.t('filters'),
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: crop,
                  decoration: InputDecoration(
                    labelText: s.t('crop'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(s.t('any')),
                    ),
                    ...cropList.map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    ),
                  ],
                  onChanged: (v) => setM(() => crop = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: district,
                  decoration: InputDecoration(
                    labelText: s.t('district'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(s.t('any')),
                    ),
                    ...districtList.map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    ),
                  ],
                  onChanged: (v) => setM(() => district = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<QtyUnit?>(
                  value: unit,
                  decoration: InputDecoration(
                    labelText: s.t('unit'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(s.t('any')),
                    ),
                    ...QtyUnit.values.map(
                          (u) => DropdownMenuItem(
                        value: u,
                        child: Text(s.t(u.key)),
                      ),
                    ),
                  ],
                  onChanged: (v) => setM(() => unit = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.t('min_qty'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(
                    '${s.t('ready_by')}: ${readyBy == null ? s.t('any') : fmtDate(readyBy!)}',
                  ),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: readyBy ??
                          DateTime.now().add(
                            const Duration(days: 7),
                          ),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    );

                    if (d != null) {
                      setM(() => readyBy = d);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          s.clearFilter();
                          Navigator.pop(ctx);
                        },
                        child: Text(s.t('clear')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          s.applyFilter(
                            crop: crop,
                            district: district,
                            unit: unit,
                            readyBy: readyBy,
                            minQty: double.tryParse(
                              minCtl.text.trim(),
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        child: Text(s.t('apply')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// BY-12: crop, grade, quantity, unit, kg equivalent, village, ready date,
// farmer FIRST name. No phone number on the card.
// Saved listing bookmark is connected to MySQL.
class ListingCard extends StatefulWidget {
  final Listing listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _isSaving = false;

  Future<void> _toggleSaved() async {
    if (_isSaving) return;

    final s = context.read<AppState>();
    final l = widget.listing;
    final wasSaved = s.isListingSaved(l.id);

    setState(() => _isSaving = true);

    try {
      if (wasSaved) {
        await s.removeSavedListing(l.id);
      } else {
        await s.saveListing(l);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasSaved
                ? 'Listing removed from saved items'
                : 'Listing saved successfully',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update saved listing: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final s = context.watch<AppState>();

    final kg = l.kg;
    final isNew = DateTime.now().difference(l.listedAt).inHours < 24;
    final days =
    (l.readyDate.difference(DateTime.now()).inHours / 24).ceil();

    final readyTag = days <= 0
        ? 'Ready now'
        : (days <= 2 ? 'Ready soon' : 'Ready in $days days');

    final readyColor =
    days <= 2 ? Colors.deepOrange : Colors.teal;

    final isSaved = s.isListingSaved(l.id);

    return GlassCard(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(
                listingId: l.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.grass),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l.crop} · ${l.variety}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: kInk,
                          ),
                        ),
                        Text(
                          '${l.village}, ${l.district}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    '${context.tr('grade')} ${l.grade}',
                    kGreen,
                  ),
                  IconButton(
                    tooltip: isSaved
                        ? 'Remove saved listing'
                        : 'Save listing',
                    onPressed: _isSaving ? null : _toggleSaved,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(
                      isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: isSaved ? kGreen : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${fmtNum(l.quantity)} ${context.tr(l.unit.key)}'
                    '${l.unit != QtyUnit.kg && kg != null ? '  (≈ ${fmtNum(kg)} ${context.tr('unit_kg')})' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (isNew)
                    const StatusPill('New', Colors.blue),
                  StatusPill(readyTag, readyColor),
                  StatusPill(
                    '₹${fmtNum(l.expectedPrice)} / ${context.tr(l.unit.key)}',
                    kInk,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(l.farmerFirstName),
                  const Spacer(),
                  Text(
                    '${context.tr('ready_date')} ${fmtDate(l.readyDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
