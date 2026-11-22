import 'package:file_picker/file_picker.dart';
import '../core/theme.dart';
import '../widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/l10n.dart';
import '../state/app_state.dart';
import 'account_screens.dart';
import 'common.dart';
import 'market_extra_screens.dart';
import 'support_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.profile;
    if (p == null) return const SizedBox();
    Widget row(String k, String v) => ListTile(dense: true, title: Text(k, style: const TextStyle(color: Colors.grey)), subtitle: Text(v.isEmpty ? '—' : v));
    return FloatingScaffold(
      bottomInset: 96,
      appBar: AppBar(title: Text(context.tr('tab_profile')), actions: const [LangSwitch()]),
      body: ListView(children: [
        const SizedBox(height: 8),
        AnimatedEntry(
          child: Column(children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [kGreenLight, kTeal]),
                  boxShadow: [BoxShadow(color: Color(0x552E7D32), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: s.profilePhoto == null ? null : MemoryImage(s.profilePhoto!),
                  child: s.profilePhoto == null ? const Icon(Icons.person, size: 72, color: kGreen) : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Material(
                  color: kGreen,
                  shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _pickPhoto(context),
                    child: const Padding(padding: EdgeInsets.all(9), child: Icon(Icons.camera_alt, size: 18, color: Colors.white)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(p.legalName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
            ),
            const SizedBox(height: 6),
            if (s.approved) const VerifiedBadge(),
          ]),
        ),
        const SizedBox(height: 12),
        row(context.tr('mobile'), '+91 ${s.phone}'),
        row(context.tr('buyer_type'), p.type),
        row(context.tr('gstin'), p.gstin),
        row(context.tr('pan'), p.pan),
        row(context.tr('reg_address'), p.regAddress),
        row(context.tr('wh_address'), p.whAddress),
        row(context.tr('contact_person'), '${p.contact} (${p.designation})'),
        row(context.tr('email'), p.email),
        row(context.tr('commodities'), p.commodities),
        row(context.tr('purchase_districts'), p.districts),
        const Divider(),
        ListTile(leading: const Icon(Icons.person_outline), title: const Text('Edit profile'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
        ListTile(leading: const Icon(Icons.folder_copy_outlined), title: const Text('My documents'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyDocumentsScreen()))),
        ListTile(leading: const Icon(Icons.bookmark_border), title: const Text('Saved listings'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedListingsScreen()))),
        ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help and support'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
        ListTile(leading: const Icon(Icons.info_outline), title: const Text('About Payir'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()))),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: Text(context.tr('edit_sensitive')),
          onTap: () => _editSensitive(context),
        ),
        ListTile(leading: const Icon(Icons.logout), title: Text(context.tr('logout')), onTap: s.logout),
      ]),
    );
  }

  /// Pick a profile photo from the gallery / files.
  Future<void> _pickPhoto(BuildContext context) async {
    final app = context.read<AppState>();
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
      app.setProfilePhoto(res.files.first.bytes);
    }
  }

  void _editSensitive(BuildContext context) {
    final s = context.read<AppState>();
    final p = s.profile!;
    final name = TextEditingController(text: p.legalName);
    final gst = TextEditingController(text: p.gstin);
    final addr = TextEditingController(text: p.regAddress);
    String? err;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(s.t('edit_sensitive')),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(s.t('sensitive_warning'), style: const TextStyle(color: Colors.deepOrange)),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: InputDecoration(labelText: s.t('legal_name'))),
              const SizedBox(height: 8),
              TextField(controller: gst, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(labelText: s.t('gstin'), errorText: err)),
              const SizedBox(height: 8),
              TextField(controller: addr, maxLines: 2, decoration: InputDecoration(labelText: s.t('reg_address'))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.t('cancel'))),
            FilledButton(
              onPressed: () {
                s.updateSensitive(legalName: name.text.trim(), gstin: gst.text.trim().toUpperCase(), regAddress: addr.text.trim());
                Navigator.pop(ctx);
              },
              child: Text(s.t('save')),
            ),
          ],
        ),
      ),
    );
  }
}
