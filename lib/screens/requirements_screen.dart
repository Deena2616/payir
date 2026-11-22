
import '../widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/units.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../core/theme.dart';
import 'common.dart';
import 'market_extra_screens.dart';
import 'shared_bits.dart';

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().loadRequirements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return FloatingScaffold(
      bottomInset: 96,
      appBar: AppBar(
        title: Text(context.tr('tab_needs')),
        actions: const [LangSwitch()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(context.tr('post_requirement')),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RequirementFormScreen(),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => app.loadRequirements(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 90),
          children: [
            GlassCard(
              color: Colors.blue.shade50,
              child: const ListTile(
                leading: Icon(Icons.campaign),
                title: Text(
                  'Post what you need. Farmers in your districts can respond.',
                ),
              ),
            ),

            if (app.isLoadingRequirements && app.requirements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (app.requirementsError != null &&
                app.requirements.isEmpty)
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
                    const Text('Could not load requirements.'),
                    const SizedBox(height: 8),
                    Text(
                      app.requirementsError!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => app.loadRequirements(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (app.requirements.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text('No requirements posted yet.'),
                  ),
                )
              else
                for (final r in app.requirements)
                  GlassCard(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 5,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RequirementDetailScreen(),
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
                                const Icon(
                                  Icons.campaign,
                                  color: kGreen,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${r.crop} · ${fmtNum(r.quantity)} ${context.tr(r.unit.key)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: kInk,
                                    ),
                                  ),
                                ),
                                StatusPill('Open', Colors.green),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${r.district} · Needed by ${fmtDate(r.neededBy)}',
                            ),
                            if (r.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  r.notes,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(
                                  Icons.groups,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text('0 farmer responses'),
                                Spacer(),
                                Icon(Icons.chevron_right),
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
    );
  }
}

// Static sample form retained in case another screen uses it.
class PostRequirementScreen extends StatelessWidget {
  const PostRequirementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: Text(context.tr('post_requirement'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: 'Paddy',
            decoration: deco('Crop'),
            items: cropList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: deco('Quantity'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'Tonne',
                  decoration: deco('Unit'),
                  items: const ['Kg', 'Bag', 'Quintal', 'Tonne']
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                  )
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: 'Thanjavur',
            decoration: deco('District'),
            items: districtList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.event),
            label: const Text('Needed by: 30-11-2026'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            decoration: deco('Notes'),
          ),
          const SizedBox(height: 12),
          GlassCard(
            color: Colors.blue.shade50,
            child: const ListTile(
              leading: Icon(Icons.info),
              title: Text(
                'Farmers in this district will be notified. You choose who to chat with.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Post requirement'),
            ),
          ),
        ],
      ),
    );
  }
}

class RequirementFormScreen extends StatefulWidget {
  const RequirementFormScreen({super.key});

  @override
  State<RequirementFormScreen> createState() =>
      _RequirementFormScreenState();
}

class _RequirementFormScreenState extends State<RequirementFormScreen> {
  final _form = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _notes = TextEditingController();

  String _crop = cropList.first;
  String _district = districtList.first;
  QtyUnit _unit = QtyUnit.tonne;

  DateTime _by = DateTime.now().add(const Duration(days: 14));
  bool _isSaving = false;

  @override
  void dispose() {
    _qty.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submitRequirement() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final app = context.read<AppState>();

      await app.postRequirement(
        Requirement(
          id: '',
          crop: _crop,
          district: _district,
          notes: _notes.text.trim(),
          quantity: double.parse(_qty.text.trim()),
          unit: _unit,
          neededBy: _by,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requirement saved successfully!'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save requirement: $e'),
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
    return FloatingScaffold(
      appBar: AppBar(
        title: Text(context.tr('post_requirement')),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _crop,
              decoration: InputDecoration(
                labelText: context.tr('crop'),
              ),
              items: cropList
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
              )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _crop = v);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.tr('quantity'),
                    ),
                    validator: (v) {
                      final quantity = double.tryParse(v ?? '');
                      return quantity != null && quantity > 0
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
                    items: QtyUnit.values
                        .map(
                          (u) => DropdownMenuItem(
                        value: u,
                        child: Text(context.tr(u.key)),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _unit = v);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _district,
              decoration: InputDecoration(
                labelText: context.tr('district'),
              ),
              items: districtList
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
              )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _district = v);
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(
                '${context.tr('needed_by')}: ${fmtDate(_by)}',
              ),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _by,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ),
                );

                if (d != null) {
                  setState(() => _by = d);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr('notes'),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.info),
                title: Text(context.tr('req_info')),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _submitRequirement,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(context.tr('post_requirement')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
