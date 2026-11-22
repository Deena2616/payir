import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass.dart';
import 'shared_bits.dart';

/// FAQ plus contact options. UI only.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Widget _faq(BuildContext context, String q, String a) => GlassCard(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(a)],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: const Text('Help and support')),
      body: ListView(children: [
        const SectionLabel('Frequently asked'),
        _faq(context, 'Why is chat locked?', 'Chat opens only after an officer approves your company. Check Profile > My documents for any file that needs re-upload.'),
        _faq(context, 'Can I see the farmer\'s phone number?', 'No. Phone numbers stay hidden. Use in-app chat to talk and agree on a deal.'),
        _faq(context, 'How do I pay the farmer?', 'Payment is made directly between you and the farmer, outside Payir.'),
        _faq(context, 'Can I cancel a deal?', 'Yes, either side can cancel before the collection date.'),
        _faq(context, 'What happens if I change my GSTIN?', 'Your account returns to Pending until an officer approves the change.'),
        const SectionLabel('Contact us'),
        const MenuTile(icon: Icons.report_problem_outlined, title: 'Report a problem', subtitle: 'Tell us what went wrong'),
        const MenuTile(icon: Icons.call, title: 'Call support', subtitle: '+91 98765 43210 · 9 AM to 6 PM'),
        const MenuTile(icon: Icons.email_outlined, title: 'Email support', subtitle: 'support@payir.example'),
        const SizedBox(height: 24),
      ]),
    );
  }
}

/// Raise a support ticket (feeds the Support queue). UI only.
class ReportProblemScreen extends StatelessWidget {
  const ReportProblemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: const Text('Report a problem')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        DropdownButtonFormField<String>(
          value: 'Chat or farmer behaviour',
          decoration: deco('Category'),
          items: const ['Chat or farmer behaviour', 'Listing information', 'Deal or agreement', 'Verification', 'App problem', 'Other']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        TextFormField(maxLines: 5, decoration: deco('Describe the problem', hint: 'What happened? When?')),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.attach_file), label: const Text('Attach screenshot (optional)')),
        const SizedBox(height: 12),
        GlassCard(
          color: Colors.amber.shade50,
          child: const ListTile(leading: Icon(Icons.info), title: Text('Our support team usually replies within 2 working days.')),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: () {}, child: const Padding(padding: EdgeInsets.all(12), child: Text('Submit'))),
      ]),
    );
  }
}

/// Version, terms and privacy links. UI only.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(title: const Text('About Payir')),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 16), children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGreenLight, kTeal]),
              boxShadow: [BoxShadow(color: Color(0x662E7D32), blurRadius: 26, offset: Offset(0, 12))],
            ),
            child: const Icon(Icons.agriculture, size: 52, color: Colors.white),
          ),
        ),
        const SizedBox(height: 14),
        const Center(child: Text('பயிர் · Payir Buyer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk))),
        const Center(child: Text('Version 1.0.0 (1)', style: TextStyle(color: Colors.grey))),
        const SizedBox(height: 16),
        const MenuTile(icon: Icons.description_outlined, title: 'Terms of Use'),
        const MenuTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
        const MenuTile(icon: Icons.article_outlined, title: 'Open-source licences'),
        const SizedBox(height: 16),
        const Center(child: Text('© Payir. All rights reserved.', style: TextStyle(color: Colors.grey))),
      ]),
    );
  }
}
