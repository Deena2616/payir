import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/glass.dart';

/// Small UI helpers reused by the new static screens.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: kInk, fontWeight: FontWeight.w800)),
  );
}

/// Glass row with icon, title, optional subtitle and chevron.
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const MenuTile({super.key, required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => GlassCard(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0x222E7D32), child: Icon(icon, color: kGreen)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    ),
  );
}

/// Label / value line used in detail screens.
class InfoRow extends StatelessWidget {
  final String label, value;
  const InfoRow(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(child: Text(value)),
    ]),
  );
}

/// Coloured status pill.
class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const StatusPill(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
  );
}

/// Static, non-interactive text field used for layout-only forms.
InputDecoration deco(String label, {String? hint, IconData? icon}) =>
    InputDecoration(labelText: label, hintText: hint, prefixIcon: icon == null ? null : Icon(icon));
