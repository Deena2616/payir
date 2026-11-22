
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/glass.dart';
import '../core/l10n.dart';
import '../core/units.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';

import 'common.dart';
import 'shared_bits.dart';

// Agreement status translation key.
String _statusKey(Agreement agreement) {
  if (agreement.cancelled) {
    return 'deal_cancelled';
  }

  if (agreement.confirmed) {
    return 'deal_confirmed';
  }

  if (!agreement.buyerConfirmed) {
    return 'deal_waiting_you';
  }

  return 'deal_waiting_farmer';
}

// Agreement status color.
Color _statusColor(Agreement agreement) {
  if (agreement.cancelled) return Colors.red;
  if (agreement.confirmed) return Colors.green;
  if (!agreement.buyerConfirmed) return Colors.orange;
  return Colors.blue;
}

// ---------- AGREEMENTS LIST ----------

class AgreementsListScreen extends StatefulWidget {
  const AgreementsListScreen({super.key});

  @override
  State<AgreementsListScreen> createState() =>
      _AgreementsListScreenState();
}

class _AgreementsListScreenState
    extends State<AgreementsListScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadAgreements();
      }
    });
  }

  List<Agreement> _filteredAgreements(
      List<Agreement> agreements,
      ) {
    switch (_filter) {
      case 'pending':
        return agreements
            .where((a) =>
        !a.cancelled && !a.confirmed)
            .toList();

      case 'confirmed':
        return agreements
            .where((a) => a.confirmed)
            .toList();

      case 'cancelled':
        return agreements
            .where((a) => a.cancelled)
            .toList();

      default:
        return agreements;
    }
  }

  Widget _count(
      String value,
      String label,
      Color color,
      ) {
    return Expanded(
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _agreementCard(
      BuildContext context,
      Agreement agreement,
      ) {
    final statusColor = _statusColor(agreement);

    return GlassCard(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 5,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AgreementDetailScreen(
                agreementId: agreement.id,
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
                  Expanded(
                    child: Text(
                      '${agreement.crop} · '
                          '${fmtNum(agreement.quantity)} '
                          '${agreement.unit.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      context.tr(_statusKey(agreement)),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                agreement.farmerName,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Text(
                      '${fmtNum(agreement.pricePerUnit)} '
                          'per ${agreement.unit.name}',
                    ),
                  ),
                  const Icon(
                    Icons.event,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fmtDate(agreement.collectionDate),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      agreement.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final agreements = app.agreements;

    final pendingCount = agreements
        .where((a) => !a.cancelled && !a.confirmed)
        .length;

    final confirmedCount =
        agreements.where((a) => a.confirmed).length;

    final waitingFarmerCount = agreements
        .where((a) =>
    !a.cancelled &&
        !a.confirmed &&
        a.buyerConfirmed)
        .length;

    final displayed = _filteredAgreements(agreements);

    return FloatingScaffold(
      bottomInset: 96,
      appBar: AppBar(
        title: Text(context.tr('tab_deals')),
        actions: const [
          LangSwitch(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: app.loadAgreements,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            8,
            4,
            8,
            12,
          ),
          children: [
            Row(
              children: [
                _count(
                  pendingCount.toString(),
                  'Pending',
                  Colors.orange,
                ),
                _count(
                  waitingFarmerCount.toString(),
                  'Waiting for farmer',
                  Colors.blue,
                ),
                _count(
                  confirmedCount.toString(),
                  'Confirmed',
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Agreement filters.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == 'all',
                    onSelected: (_) {
                      setState(() => _filter = 'all');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Pending'),
                    selected: _filter == 'pending',
                    onSelected: (_) {
                      setState(() => _filter = 'pending');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Confirmed'),
                    selected: _filter == 'confirmed',
                    onSelected: (_) {
                      setState(() => _filter = 'confirmed');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Cancelled'),
                    selected: _filter == 'cancelled',
                    onSelected: (_) {
                      setState(() => _filter = 'cancelled');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            if (app.isLoadingAgreements &&
                agreements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (app.agreementsError != null &&
                agreements.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Could not load agreements.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      app.agreementsError!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: app.loadAgreements,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (displayed.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.handshake_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        agreements.isEmpty
                            ? 'No agreements yet.'
                            : 'No agreements in this category.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...displayed.map(
                      (agreement) => _agreementCard(
                    context,
                    agreement,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ---------- AGREEMENT FORM ----------

class AgreementFormScreen extends StatefulWidget {
  final String listingId;

  const AgreementFormScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<AgreementFormScreen> createState() =>
      _AgreementFormScreenState();
}

class _AgreementFormScreenState
    extends State<AgreementFormScreen> {
  final _form = GlobalKey<FormState>();

  Listing? _listing;

  late final TextEditingController _qty;
  late final TextEditingController _price;
  late final TextEditingController _place;

  late QtyUnit _unit;
  DateTime? _date;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _listing = context.read<AppState>().listingById(
      widget.listingId,
    );

    if (_listing != null) {
      final listing = _listing!;

      _qty = TextEditingController(
        text: fmtNum(listing.quantity).replaceAll(',', ''),
      );

      _price = TextEditingController(
        text: listing.expectedPrice.toStringAsFixed(0),
      );

      _place = TextEditingController(
        text: '${listing.village}, ${listing.district}',
      );

      _unit = listing.unit;
      _date = listing.readyDate;
    } else {
      _qty = TextEditingController();
      _price = TextEditingController();
      _place = TextEditingController();

      _unit = QtyUnit.bag;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    _place.dispose();

    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (_isSubmitting) return;

    if (!_form.currentState!.validate()) {
      return;
    }

    final listing = _listing;

    if (listing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing could not be found.'),
        ),
      );
      return;
    }

    final date = _date;

    if (date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a collection date.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final agreement =
      await context.read<AppState>().proposeAgreement(
        listing: listing,
        quantity: double.parse(_qty.text.trim()),
        unit: _unit,
        price: double.parse(_price.text.trim()),
        place: _place.text.trim(),
        date: date,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AgreementDetailScreen(
            agreementId: agreement.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not send proposal: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = _listing;

    if (listing == null) {
      return FloatingScaffold(
        appBar: AppBar(
          title: const Text('Agreement'),
        ),
        body: const Center(
          child: Text('Listing not found.'),
        ),
      );
    }

    return FloatingScaffold(
      appBar: AppBar(
        title: Text(
          '${context.tr('agreement')} · ${listing.crop}',
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.tr('quantity'),
                    ),
                    validator: (value) {
                      final quantity =
                      double.tryParse(value ?? '');

                      return quantity != null &&
                          quantity > 0
                          ? null
                          : context.app.t('required');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<QtyUnit>(
                    value: _unit,
                    decoration: InputDecoration(
                      labelText: context.tr('unit'),
                    ),
                    items: QtyUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(
                          context.tr(unit.key),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _unit = value);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _price,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.tr('price_per_unit'),
              ),
              validator: (value) {
                final price =
                double.tryParse(value ?? '');

                return price != null && price > 0
                    ? null
                    : context.app.t('required');
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _place,
              decoration: InputDecoration(
                labelText: context.tr('collection_place'),
              ),
              validator: (value) {
                return (value ?? '').trim().isEmpty
                    ? context.app.t('required')
                    : null;
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(
                '${context.tr('collection_date')}: '
                    '${fmtDate(_date!)}',
              ),
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _date!,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ),
                );

                if (selectedDate != null && mounted) {
                  setState(() => _date = selectedDate);
                }
              },
            ),

            const SizedBox(height: 12),

            GlassCard(
              color: Colors.amber.shade50,
              child: ListTile(
                leading: const Icon(Icons.info),
                title: Text(
                  context.tr('payment_note'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed:
              _isSubmitting ? null : _submitProposal,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  context.tr('send_proposal'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- AGREEMENT DETAIL ----------

class AgreementDetailScreen extends StatefulWidget {
  final String agreementId;

  const AgreementDetailScreen({
    super.key,
    required this.agreementId,
  });

  @override
  State<AgreementDetailScreen> createState() =>
      _AgreementDetailScreenState();
}

class _AgreementDetailScreenState
    extends State<AgreementDetailScreen> {
  bool _isUpdating = false;

  Future<void> _confirm(Agreement agreement) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      await context.read<AppState>().confirmAgreement(
        agreement,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your confirmation has been saved.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not confirm agreement: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _cancel(Agreement agreement) async {
    if (_isUpdating) return;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel agreement?'),
          content: const Text(
            'Are you sure you want to cancel this agreement?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep agreement'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Cancel agreement'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !mounted) return;

    setState(() => _isUpdating = true);

    try {
      await context.read<AppState>().cancelAgreement(
        agreement,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agreement cancelled successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not cancel agreement: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _infoRow(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _progressStep(
      IconData icon,
      String title,
      String subtitle,
      bool done,
      ) {
    return ListTile(
      dense: true,
      leading: Icon(
        done
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
        color: done ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final agreement =
    app.agreementById(widget.agreementId);

    if (agreement == null) {
      return FloatingScaffold(
        appBar: AppBar(
          title: const Text('Agreement'),
        ),
        body: Center(
          child: app.isLoadingAgreements
              ? const CircularProgressIndicator()
              : const Text('Agreement not found.'),
        ),
      );
    }

    final kg = toKg(
      agreement.quantity,
      agreement.unit,
      agreement.crop,
    );

    final statusColor = _statusColor(agreement);

    return FloatingScaffold(
      appBar: AppBar(
        title: Text(app.t('agreement')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Center(
            child: Chip(
              label: Text(
                app.t(_statusKey(agreement)),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor:
              statusColor.withValues(alpha: 0.10),
            ),
          ),

          GlassCard(
            child: Column(
              children: [
                _infoRow(
                  app.t('crop'),
                  agreement.crop,
                ),
                _infoRow(
                  app.t('farmer'),
                  agreement.farmerName,
                ),
                _infoRow(
                  app.t('quantity'),
                  '${fmtNum(agreement.quantity)} '
                      '${app.t(agreement.unit.key)}'
                      '${agreement.unit != QtyUnit.kg && kg != null ? '  (≈ ${fmtNum(kg)} ${app.t('unit_kg')})' : ''}',
                ),
                _infoRow(
                  app.t('price_per_unit'),
                  '₹${fmtNum(agreement.pricePerUnit)}',
                ),
                _infoRow(
                  app.t('collection_place'),
                  agreement.place,
                ),
                _infoRow(
                  app.t('collection_date'),
                  fmtDate(agreement.collectionDate),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const SectionLabel('Progress'),

          GlassCard(
            child: Column(
              children: [
                _progressStep(
                  Icons.send,
                  'Proposal sent',
                  'Saved in your buyer account',
                  true,
                ),
                _progressStep(
                  Icons.person,
                  'Farmer confirmed',
                  agreement.farmerConfirmed
                      ? 'Confirmed'
                      : 'Waiting for farmer',
                  agreement.farmerConfirmed,
                ),
                _progressStep(
                  Icons.handshake,
                  'You confirm',
                  agreement.buyerConfirmed
                      ? 'Confirmed'
                      : 'Waiting for your confirmation',
                  agreement.buyerConfirmed,
                ),
                _progressStep(
                  Icons.local_shipping,
                  'Collection',
                  fmtDate(agreement.collectionDate),
                  agreement.confirmed,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          GlassCard(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                app.t('payment_note'),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (!agreement.cancelled &&
              !agreement.buyerConfirmed)
            Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton(
                onPressed: _isUpdating
                    ? null
                    : () => _confirm(agreement),
                child: _isUpdating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(app.t('confirm')),
              ),
            ),

          if (agreement.canCancel)
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: _isUpdating
                    ? null
                    : () => _cancel(agreement),
                child: Text(
                  app.t('cancel_deal'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
