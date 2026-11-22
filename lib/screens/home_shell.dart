import 'package:flutter/material.dart';
import '../widgets/glass.dart';
import 'agreements_screens.dart';
import 'chat_screens.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'requirements_screen.dart';

/// Bottom navigation. The only state here is which tab is showing.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  static const _pages = <Widget>[DashboardScreen(), ChatsListScreen(), AgreementsListScreen(), RequirementsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => BlurFade(animation: anim, maxBlur: 8, dy: 16, child: child),
            child: KeyedSubtree(key: ValueKey(_i), child: _pages[_i]),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingNavBar(
            index: _i,
            onChanged: (v) => setState(() => _i = v),
            items: const [
              NavItemData(Icons.storefront_outlined, Icons.storefront, 'Market'),
              NavItemData(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chats', badge: 3),
              NavItemData(Icons.handshake_outlined, Icons.handshake, 'Deals'),
              NavItemData(Icons.campaign_outlined, Icons.campaign, 'Needs'),
              NavItemData(Icons.business_outlined, Icons.business, 'Profile'),
            ],
          ),
        ),
      ]),
    );
  }
}
