
import '../widgets/glass.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../core/l10n.dart';
import '../core/units.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';
import 'common.dart';

// BY-02..BY-06, BY-21. Also used to re-submit after a return (BY-08).
class RegistrationScreen extends StatefulWidget {
  final bool editing;

  const RegistrationScreen({super.key, this.editing = false});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _form = GlobalKey<FormState>();
  late final CompanyProfile _p;
  final Map<String, TextEditingController> _c = {};

  final Map<String, PlatformFile> _selectedDocuments = {};

  bool _isSubmitting = false;
  String? _errorMessage;

  static const _docKeys = [
    'doc_gst',
    'doc_pan',
    'doc_address',
    'doc_photo'
  ];

  TextEditingController _ctl(String k, String initial) =>
      _c.putIfAbsent(k, () => TextEditingController(text: initial));

  @override
  void initState() {
    super.initState();
    _p = widget.editing
        ? (context.app.profile ?? CompanyProfile())
        : CompanyProfile();
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(
      String key,
      String initial, {
        bool req = true,
        TextInputType? kb,
        bool upper = false,
        String? Function(String)? extra,
        int lines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _ctl(key, initial),
        keyboardType: kb,
        maxLines: lines,
        textCapitalization: upper
            ? TextCapitalization.characters
            : TextCapitalization.none,
        decoration: InputDecoration(labelText: context.tr(key)),
        validator: (v) {
          final val = (v ?? '').trim();

          if (req && val.isEmpty) {
            return context.app.t('required');
          }

          if (val.isNotEmpty && extra != null) {
            return extra(val);
          }

          return null;
        },
      ),
    );
  }

  Widget _section(String key) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      context.tr(key),
      style: Theme.of(context).textTheme.titleMedium,
    ),
  );

  Future<void> _pick(String key) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (!mounted) return;

    if (res != null && res.files.isNotEmpty) {
      final file = res.files.first;

      if (file.bytes == null) {
        setState(() {
          _errorMessage = 'Could not read the selected file. Try again.';
        });
        return;
      }

      setState(() {
        _selectedDocuments[key] = file;
        _p.docs[key] = file.name;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final app = context.app;

    if (!_form.currentState!.validate()) return;

    // The current PHP endpoint creates a new registration.
    // Do not use it for editing an existing profile.
    if (widget.editing) {
      setState(() {
        _errorMessage =
        'Profile editing is not connected to the backend yet.';
      });
      return;
    }

    if (app.phone.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Mobile number is missing. Please log in again.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    String v(String k) => _c[k]!.text.trim();

    _p
      ..legalName = v('legal_name')
      ..tradeName = v('trade_name')
      ..gstin = v('gstin').toUpperCase()
      ..pan = v('pan').toUpperCase()
      ..cin = v('cin')
      ..fssai = v('fssai')
      ..regAddress = v('reg_address')
      ..whAddress = v('wh_address')
      ..contact = v('contact_person')
      ..designation = v('designation')
      ..email = v('email')
      ..commodities = v('commodities')
      ..monthlyVolume = v('monthly_volume')
      ..districts = v('purchase_districts')
      ..varieties = v('varieties');

    try {
      await ApiService.registerBuyer(
        mobile: app.phone,
        profile: _p,
        documents: _selectedDocuments,
      );

      if (!mounted) return;

      // Update local app state only after backend success.
      app.submitApplication(_p);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(
        title: Text(context.tr('register_title')),
        actions: const [LangSwitch()],
      ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section('sec_company'),
              _field('legal_name', _p.legalName),
              _field('trade_name', _p.tradeName, req: false),

              DropdownButtonFormField<String>(
                value: _p.type,
                decoration: InputDecoration(
                  labelText: context.tr('buyer_type'),
                ),
                items: buyerTypes
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _p.type = v ?? 'trader';
                }),
              ),

              _section('sec_tax'),
              _field('gstin', _p.gstin, upper: true),

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  context.tr('gstin_note'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              _field('pan', _p.pan, upper: true),
              _field('cin', _p.cin, req: false, upper: true),
              _field(
                'fssai',
                _p.fssai,
                req: false,
                kb: TextInputType.number,
              ),

              _section('sec_address'),
              _field('reg_address', _p.regAddress, lines: 2),
              _field('wh_address', _p.whAddress, lines: 2),
              _field('contact_person', _p.contact),
              _field('designation', _p.designation),
              _field(
                'email',
                _p.email,
                kb: TextInputType.emailAddress,
              ),

              _section('sec_buying'),
              _field('commodities', _p.commodities),

              Row(
                children: [
                  Expanded(
                    child: _field(
                      'monthly_volume',
                      _p.monthlyVolume,
                      kb: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<QtyUnit>(
                        value: _p.volumeUnit,
                        decoration: InputDecoration(
                          labelText: context.tr('unit'),
                        ),
                        items: QtyUnit.values
                            .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(context.tr(u.key)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _p.volumeUnit = v ?? QtyUnit.tonne;
                        }),
                      ),
                    ),
                  ),
                ],
              ),

              _field('purchase_districts', _p.districts),
              _field('varieties', _p.varieties, req: false),

              Text(context.tr('languages')),

              Wrap(
                spacing: 8,
                children: [
                  for (final l in ['Tamil', 'English', 'Hindi'])
                    FilterChip(
                      label: Text(l),
                      selected: _p.languages.contains(l),
                      onSelected: (sel) => setState(() {
                        if (sel) {
                          _p.languages.add(l);
                        } else {
                          _p.languages.remove(l);
                        }
                      }),
                    ),
                ],
              ),

              _section('sec_docs'),

              for (final k in _docKeys)
                GlassCard(
                  child: ListTile(
                    leading: Icon(
                      _p.docs.containsKey(k)
                          ? Icons.check_circle
                          : Icons.upload_file,
                      color: _p.docs.containsKey(k)
                          ? Colors.green
                          : null,
                    ),
                    title: Text(context.tr(k)),
                    subtitle: Text(
                      _p.docs[k] ?? context.tr('optional'),
                    ),
                    trailing: TextButton(
                      onPressed: _isSubmitting ? null : () => _pick(k),
                      child: Text(context.tr('choose_file')),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(context.tr('submit')),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
