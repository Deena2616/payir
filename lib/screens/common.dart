import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/l10n.dart';
import '../state/app_state.dart';

/// English / Tamil toggle shown in app bars.
class LangSwitch extends StatelessWidget {
  const LangSwitch({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return TextButton(
      onPressed: () => s.setTamil(!s.isTamil),
      child: Text(s.isTamil ? 'English' : 'தமிழ்'),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.verified, color: Colors.green, size: 18),
      label: Text(context.tr('verified_badge')),
      visualDensity: VisualDensity.compact,
    );
  }
}

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
