import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass.dart';

/// Shown once before login: choose English or Tamil (SH-06). UI only.
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});
  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  int _sel = 0;

  Widget _option(int i, String title, String sub) {
    final on = _sel == i;
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: on ? const Color(0xCCE8F5E9) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kInk)),
        subtitle: Text(sub),
        trailing: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: kGreen),
        onTap: () => setState(() => _sel = i),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: const Text('Language / மொழி')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGreenLight, kTeal]),
            ),
            child: const Icon(Icons.translate, size: 48, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Choose your language', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
        const Text('உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்', textAlign: TextAlign.center),
        const SizedBox(height: 20),
        _option(0, 'English', 'Use the app in English'),
        _option(1, 'தமிழ்', 'பயன்பாட்டை தமிழில் பயன்படுத்தவும்'),
        const SizedBox(height: 24),
        FilledButton(onPressed: () {}, child: const Padding(padding: EdgeInsets.all(12), child: Text('Continue'))),
        const SizedBox(height: 8),
        const Text('You can change this later in Settings.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ]),
    );
  }
}

/// Terms of use and privacy consent before registration. UI only.
class TermsConsentScreen extends StatefulWidget {
  const TermsConsentScreen({super.key});
  @override
  State<TermsConsentScreen> createState() => _TermsConsentScreenState();
}

class _TermsConsentScreenState extends State<TermsConsentScreen> {
  bool _terms = false, _privacy = false, _noPayment = false;

  @override
  Widget build(BuildContext context) {
    Widget point(IconData i, String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, size: 20, color: kGreen),
        const SizedBox(width: 10),
        Expanded(child: Text(t)),
      ]),
    );
    return FloatingScaffold(
      appBar: AppBar(title: const Text('Terms and privacy')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Before you continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 8),
              point(Icons.verified_user, 'Only verified company buyers can chat with farmers and confirm deals.'),
              point(Icons.privacy_tip, 'Farmer phone numbers are never shown. Chat happens inside Payir.'),
              point(Icons.payments, 'Payment is made directly between you and the farmer, outside Payir.'),
              point(Icons.gavel, 'Misuse, spam or abusive chat can lead to suspension of your account.'),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: Column(children: [
            CheckboxListTile(value: _terms, onChanged: (v) => setState(() => _terms = v ?? false), title: const Text('I accept the Terms of Use')),
            CheckboxListTile(value: _privacy, onChanged: (v) => setState(() => _privacy = v ?? false), title: const Text('I accept the Privacy Policy')),
            CheckboxListTile(value: _noPayment, onChanged: (v) => setState(() => _noPayment = v ?? false), title: const Text('I understand Payir does not handle payments')),
          ]),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: () {}, child: const Padding(padding: EdgeInsets.all(12), child: Text('Accept and continue'))),
      ]),
    );
  }
}