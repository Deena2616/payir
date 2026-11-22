import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Fade + slide + BLUR-IN. Same widget structure at every value, so state is never lost.
class BlurFade extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double maxBlur, dy;
  const BlurFade({super.key, required this.animation, required this.child, this.maxBlur = 10, this.dy = 30});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, c) {
        final v = animation.value.clamp(0.0, 1.0);
        final sigma = (1 - v) * maxBlur;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * dy),
            child: ImageFiltered(
              enabled: sigma > 0.2,
              imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
              child: c,
            ),
          ),
        );
      },
    );
  }
}

/// Motion-blur page transition used for every route.
class BlurPageTransitionsBuilder extends PageTransitionsBuilder {
  const BlurPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: secondaryAnimation.drive(Tween<double>(begin: 1, end: 0)),
      child: BlurFade(animation: curved, maxBlur: 10, dy: 36, child: child),
    );
  }
}

/// Staggered entrance for list items / blocks.
class AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final double dy, blur;
  const AnimatedEntry({super.key, required this.child, this.index = 0, this.dy = 26, this.blur = 8});
  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 60 * math.min(widget.index, 8)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlurFade(animation: _a, maxBlur: widget.blur, dy: widget.dy, child: widget.child);
}

/// Slowly drifting colour blobs behind the whole app.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});
  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _blob(Alignment a, double size, int rgb) => Align(
    alignment: a,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color(0x99000000 | rgb), Color(0x00000000 | rgb)]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), Color(0xFFE0F2F1)],
              ),
            ),
            child: Stack(fit: StackFit.expand, children: [
              _blob(Alignment(math.sin(t) * .9, math.cos(t) * .7), 420, 0x66BB6A),
              _blob(Alignment(math.cos(t + 2) * .9, math.sin(t + 1) * .8), 340, 0x26A69A),
              _blob(Alignment(math.sin(t + 4) * .8, math.cos(t + 3) * .9), 300, 0xFFD54F),
            ]),
          );
        },
      ),
    );
  }
}

/// Frosted-glass card (replacement for Card).
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry margin;
  const GlassCard({super.key, required this.child, this.color, this.margin = const EdgeInsets.all(4)});

  @override
  Widget build(BuildContext context) {
    const r = BorderRadius.all(Radius.circular(22));
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: r,
          boxShadow: [BoxShadow(color: Color(0x1F1B5E20), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Material(
          color: color ?? kGlassFill,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(borderRadius: r, side: BorderSide(color: kGlassBorder)),
          child: child,
        ),
      ),
    );
  }
}

/// Floating, blurred header bar.
class GlassHeader extends StatelessWidget {
  final Widget? title;
  final List<Widget> actions;
  final bool showBack;
  const GlassHeader({super.key, this.title, this.actions = const [], this.showBack = false});

  @override
  Widget build(BuildContext context) {
    const r = BorderRadius.all(Radius.circular(30));
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: r,
        boxShadow: [BoxShadow(color: Color(0x261B5E20), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(color: kGlassBorder),
              gradient: const LinearGradient(colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF)]),
            ),
            child: Row(children: [
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kInk),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(radius: 17, backgroundColor: kGreen, child: Icon(Icons.agriculture, size: 19, color: Colors.white)),
                ),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kInk),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: title ?? const SizedBox(),
                ),
              ),
              IconTheme(
                data: const IconThemeData(color: kInk),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Drop-in for Scaffold: floating glass header on top, content below it.
/// Pass the same `appBar: AppBar(title:..., actions:...)` as before.
class FloatingScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final double bottomInset;
  const FloatingScaffold({super.key, this.appBar, required this.body, this.floatingActionButton, this.bottomInset = 0});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bar = appBar is AppBar ? appBar as AppBar : null;
    final bottom = bottomInset + mq.padding.bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: mq.padding.top + 76, bottom: bottom),
            child: MediaQuery.removePadding(context: context, removeTop: true, removeBottom: true, child: body),
          ),
        ),
        Positioned(
          top: mq.padding.top + 8,
          left: 12,
          right: 12,
          child: AnimatedEntry(
            dy: -24,
            blur: 6,
            child: GlassHeader(title: bar?.title, actions: bar?.actions ?? const [], showBack: Navigator.of(context).canPop()),
          ),
        ),
        if (floatingActionButton != null) Positioned(right: 16, bottom: bottom + 12, child: floatingActionButton!),
      ]),
    );
  }
}

class NavItemData {
  final IconData icon, activeIcon;
  final String label;
  final int badge;
  const NavItemData(this.icon, this.activeIcon, this.label, {this.badge = 0});
}

/// Floating, blurred, pill-shaped bottom bar with an animated selected pill.
class FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItemData> items;
  const FloatingNavBar({super.key, required this.index, required this.onChanged, required this.items});

  @override
  Widget build(BuildContext context) {
    const r = BorderRadius.all(Radius.circular(34));
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, MediaQuery.of(context).padding.bottom + 12),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: r,
          boxShadow: [BoxShadow(color: Color(0x331B5E20), blurRadius: 28, offset: Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: r,
                border: Border.all(color: kGlassBorder),
                gradient: const LinearGradient(colors: [Color(0xD9FFFFFF), Color(0x80FFFFFF)]),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                for (int i = 0; i < items.length; i++) _NavButton(data: items[i], selected: i == index, onTap: () => onChanged(i)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItemData data;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected ? data.activeIcon : data.icon, size: 24, color: selected ? Colors.white : kInk);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: selected ? const LinearGradient(colors: [kGreenLight, kTeal]) : null,
          boxShadow: selected ? const [BoxShadow(color: Color(0x662E7D32), blurRadius: 14, offset: Offset(0, 6))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          data.badge > 0 ? Badge(label: Text('${data.badge}'), child: icon) : icon,
          AnimatedSize(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            child: selected
                ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 74),
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            )
                : const SizedBox(width: 0, height: 0),
          ),
        ]),
      ),
    );
  }
}
