
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/units.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/glass.dart';
import 'shared_bits.dart';

// Edit buyer details that do NOT need re-verification.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _contactController = TextEditingController();
  final _designationController = TextEditingController();
  final _emailController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _commoditiesController = TextEditingController();
  final _volumeController = TextEditingController();
  final _districtsController = TextEditingController();
  final _varietiesController = TextEditingController();

  QtyUnit _volumeUnit = QtyUnit.tonne;

  List<String> _languages = ['Tamil', 'English'];

  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final app = Provider.of<AppState>(
      context,
      listen: false,
    );

    final profile = app.profile;

    if (profile != null) {
      _contactController.text = profile.contact;
      _designationController.text = profile.designation;
      _emailController.text = profile.email;
      _warehouseController.text = profile.whAddress;
      _commoditiesController.text = profile.commodities;
      _volumeController.text = profile.monthlyVolume;
      _districtsController.text = profile.districts;
      _varietiesController.text = profile.varieties;

      _volumeUnit = profile.volumeUnit;
      _languages = List<String>.from(profile.languages);
    }

    _initialized = true;
  }

  Widget _f(
      String label, {
        required TextEditingController controller,
        int lines = 1,
        IconData? icon,
        TextInputType? kb,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: kb,
        validator: validator,
        decoration: deco(label, icon: icon),
      ),
    );
  }

  String _unitLabel(QtyUnit unit) {
    switch (unit) {
      case QtyUnit.kg:
        return 'Kg';
      case QtyUnit.bag:
        return 'Bag';
      case QtyUnit.quintal:
        return 'Quintal';
      case QtyUnit.tonne:
        return 'Tonne';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final app = Provider.of<AppState>(
      context,
      listen: false,
    );

    final existing = app.profile;

    if (existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buyer profile not found.'),
        ),
      );
      return;
    }

    // Create a separate profile object.
    // Keep legal and verification details unchanged.
    final updated = CompanyProfile()
      ..legalName = existing.legalName
      ..tradeName = existing.tradeName
      ..type = existing.type
      ..gstin = existing.gstin
      ..pan = existing.pan
      ..cin = existing.cin
      ..fssai = existing.fssai
      ..regAddress = existing.regAddress
      ..contact = _contactController.text.trim()
      ..designation = _designationController.text.trim()
      ..email = _emailController.text.trim()
      ..whAddress = _warehouseController.text.trim()
      ..commodities = _commoditiesController.text.trim()
      ..monthlyVolume = _volumeController.text.trim()
      ..volumeUnit = _volumeUnit
      ..districts = _districtsController.text.trim()
      ..varieties = _varietiesController.text.trim()
      ..languages = List<String>.from(_languages)
      ..docs = Map<String, String>.from(existing.docs);

    setState(() {
      _saving = true;
    });

    try {
      await app.saveBuyerProfile(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _warehouseController.dispose();
    _commoditiesController.dispose();
    _volumeController.dispose();
    _districtsController.dispose();
    _varietiesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return FloatingScaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              color: Colors.blue.shade50,
              child: const ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  'Legal name, GSTIN and registered address are changed from Profile > Change legal details. That needs re-approval.',
                ),
              ),
            ),

            const SizedBox(height: 12),

            _f(
              'Contact person',
              controller: _contactController,
              icon: Icons.person,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Enter contact person'
                  : null,
            ),

            _f(
              'Designation',
              controller: _designationController,
              icon: Icons.badge,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Enter designation'
                  : null,
            ),

            _f(
              'Email',
              controller: _emailController,
              icon: Icons.email,
              kb: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter email address';
                }

                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }

                return null;
              },
            ),

            _f(
              'Warehouse address',
              controller: _warehouseController,
              lines: 2,
              icon: Icons.warehouse,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Enter warehouse address'
                  : null,
            ),

            _f(
              'Commodities',
              controller: _commoditiesController,
              icon: Icons.grass,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Enter commodities'
                  : null,
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _f(
                    'Monthly volume',
                    controller: _volumeController,
                    kb: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final number = double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (number == null || number <= 0) {
                        return 'Enter valid volume';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<QtyUnit>(
                      value: _volumeUnit,
                      decoration: deco('Unit'),
                      items: QtyUnit.values.map((unit) {
                        return DropdownMenuItem<QtyUnit>(
                          value: unit,
                          child: Text(_unitLabel(unit)),
                        );
                      }).toList(),
                      onChanged: _saving
                          ? null
                          : (value) {
                        if (value != null) {
                          setState(() {
                            _volumeUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            _f(
              'Purchase districts',
              controller: _districtsController,
              icon: Icons.place,
              validator: (value) =>
              value == null || value.trim().isEmpty
                  ? 'Enter purchase districts'
                  : null,
            ),

            _f(
              'Varieties',
              controller: _varietiesController,
            ),

            const SizedBox(height: 8),

            const Text(
              'Languages',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                for (final language in [
                  'Tamil',
                  'English',
                  'Hindi',
                ])
                  FilterChip(
                    label: Text(language),
                    selected: _languages.contains(language),
                    onSelected: _saving
                        ? null
                        : (selected) {
                      setState(() {
                        if (selected) {
                          _languages.add(language);
                        } else {
                          _languages.remove(language);
                        }
                      });
                    },
                  ),
              ],
            ),

            if (_languages.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Select at least one language.',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: _saving || !app.approved || _languages.isEmpty
                  ? null
                  : _saveProfile,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The four registration documents with their review status.
class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  Widget _doc(
      String title,
      String file,
      String status,
      Color c, {
        bool reupload = false,
      }) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description,
                  color: kGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusPill(status, c),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              file,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),

                const SizedBox(width: 8),

                if (reupload)
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Replace'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(
        title: const Text('My documents'),
      ),
      body: ListView(
        children: [
          _doc(
            'GST certificate',
            'gst_certificate.pdf',
            'Verified',
            Colors.green,
          ),
          _doc(
            'PAN card',
            'pan_card.jpg',
            'Verified',
            Colors.green,
          ),
          _doc(
            'Address proof',
            'address_proof.png',
            'Re-upload',
            Colors.deepOrange,
            reupload: true,
          ),
          _doc(
            'Premises photo',
            'warehouse.jpg',
            'Under review',
            Colors.orange,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Accepted formats: PDF, JPG, PNG.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// App settings: language, notification switches, about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _chat = true;
  bool _deals = true;
  bool _supply = true;
  bool _status = true;

  Widget _sw(
      String t,
      String sub,
      bool v,
      ValueChanged<bool> on,
      ) =>
      GlassCard(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        child: SwitchListTile(
          value: v,
          onChanged: on,
          title: Text(t),
          subtitle: Text(sub),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SectionLabel('General'),

          const MenuTile(
            icon: Icons.translate,
            title: 'Language',
            subtitle: 'English',
          ),

          const SectionLabel('Notifications'),

          _sw(
            'New messages',
            'When a farmer replies in chat',
            _chat,
                (v) => setState(() => _chat = v),
          ),

          _sw(
            'Deal updates',
            'Confirmations and cancellations',
            _deals,
                (v) => setState(() => _deals = v),
          ),

          _sw(
            'New supply',
            'New listings in your districts',
            _supply,
                (v) => setState(() => _supply = v),
          ),

          _sw(
            'Verification status',
            'Approval or return of your application',
            _status,
                (v) => setState(() => _status = v),
          ),

          const SectionLabel('Account'),

          const MenuTile(
            icon: Icons.folder_copy,
            title: 'My documents',
          ),

          const MenuTile(
            icon: Icons.help_outline,
            title: 'Help and support',
          ),

          const MenuTile(
            icon: Icons.info_outline,
            title: 'About Payir',
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
