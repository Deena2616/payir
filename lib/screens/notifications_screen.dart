import '../widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/l10n.dart';
import '../core/units.dart';
import '../state/app_state.dart';

/// SH-01: notification centre with read / unread state.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final AppState _app;
  late final Set<int> _unreadAtOpen;

  @override
  void initState() {
    super.initState();
    _app = context.read<AppState>();
    _unreadAtOpen = {
      for (int i = 0; i < _app.notifications.length; i++)
        if (!_app.notifications[i].read) i
    };
    Future.microtask(_app.markAllRead);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return FloatingScaffold(
      appBar: AppBar(
        title: Text(s.t('notifications')),
        actions: [
          if (s.notifications.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear_all), tooltip: 'Clear all', onPressed: s.clearNotifications),
        ],
      ),
      body: s.notifications.isEmpty
          ? Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.black26),
          const SizedBox(height: 8),
          Text(s.t('no_notifs')),
        ]),
      )
          : ListView.separated(
        itemCount: s.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = s.notifications[i];
          final wasUnread = _unreadAtOpen.contains(i);
          return ListTile(
            leading: Icon(wasUnread ? Icons.circle : Icons.circle_outlined, size: 12, color: Colors.green),
            title: Text(s.isTamil ? n.titleTa : n.titleEn, style: TextStyle(fontWeight: wasUnread ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(s.isTamil ? n.bodyTa : n.bodyEn),
            trailing: Text(fmtTime(n.time), style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }
}
