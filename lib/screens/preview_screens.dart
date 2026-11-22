import 'package:flutter/material.dart';
import '../widgets/glass.dart';
import 'account_screens.dart';
import 'market_extra_screens.dart';
import 'onboarding_screens.dart';
import 'shared_bits.dart';
import 'support_screens.dart';

/// Temporary index so you can open every new static screen while wiring navigation.
/// Delete this file once each screen is linked from its real entry point.
class PreviewMenuScreen extends StatelessWidget {
  const PreviewMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    Widget tile(IconData i, String t, Widget w) => MenuTile(icon: i, title: t, onTap: () => open(w));
    return FloatingScaffold(
      appBar: AppBar(title: const Text('New screens preview')),
      body: ListView(children: [
        const SectionLabel('Onboarding'),
        tile(Icons.translate, 'Language select', const LanguageSelectScreen()),
        tile(Icons.gavel, 'Terms and privacy', const TermsConsentScreen()),
        const SectionLabel('Market'),
        tile(Icons.person, 'Farmer profile', const FarmerProfileScreen()),
        tile(Icons.photo_library, 'Photo gallery', const PhotoGalleryScreen()),
        tile(Icons.bookmark, 'Saved listings', const SavedListingsScreen()),
        tile(Icons.campaign, 'Requirement detail', const RequirementDetailScreen()),
        const SectionLabel('Account'),
        tile(Icons.edit, 'Edit profile', const EditProfileScreen()),
        tile(Icons.folder_copy, 'My documents', const MyDocumentsScreen()),
        tile(Icons.settings, 'Settings', const SettingsScreen()),
        const SectionLabel('Support'),
        tile(Icons.help_outline, 'Help and support', const HelpSupportScreen()),
        tile(Icons.report_problem_outlined, 'Report a problem', const ReportProblemScreen()),
        tile(Icons.info_outline, 'About Payir', const AboutScreen()),
        const SizedBox(height: 24),
      ]),
    );
  }
}
