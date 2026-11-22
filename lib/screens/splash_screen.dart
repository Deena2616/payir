import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/glass.dart';

/// Animated launch screen: logo pops in, glow ring spins, title blur-ins, progress fills.
class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({super.key, required this.next});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  Animation<double> _iv(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => widget.next,
        transitionsBuilder: (_, anim, __, child) => BlurFade(animation: anim, maxBlur: 16, dy: 0, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = _iv(0.0, 0.5, Curves.easeOutBack);
    final title = _iv(0.35, 0.75);
    final tag = _iv(0.55, 0.9);
    final bar = _iv(0.15, 1.0, Curves.easeInOut);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF00695C)]),
        ),
        child: Stack(fit: StackFit.expand, children: [
          AnimatedBuilder(
            animation: _spin,
            builder: (_, __) {
              final t = _spin.value * 2 * math.pi;
              Widget orb(Alignment a, double s, double o) => Align(
                alignment: a,
                child: Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, o))),
              );
              return Stack(fit: StackFit.expand, children: [
                orb(Alignment(math.sin(t) * .8, -.7 + math.cos(t) * .1), 200, .06),
                orb(Alignment(math.cos(t) * .9, .6 + math.sin(t) * .1), 260, .05),
                orb(Alignment(-.8 + math.sin(t * 2) * .1, .1), 120, .07),
              ]);
            },
          ),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ScaleTransition(
                scale: logo,
                child: FadeTransition(
                  opacity: _iv(0.0, 0.25),
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(alignment: Alignment.center, children: [
                      RotationTransition(
                        turns: _spin,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(colors: [Color(0x00FFFFFF), Color(0xCCFFFFFF), Color(0x00FFFFFF)]),
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFC8E6C9)]),
                          boxShadow: [BoxShadow(color: Color(0x66FFFFFF), blurRadius: 40, spreadRadius: 4)],
                        ),
                        child: const Icon(Icons.agriculture, size: 72, color: Color(0xFF2E7D32)),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              BlurFade(
                animation: title,
                maxBlur: 14,
                dy: 22,
                child: const Text('பயிர் · Payir', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              BlurFade(
                animation: tag,
                maxBlur: 8,
                dy: 14,
                child: const Text('BUYER  ·  வாங்குபவர்', style: TextStyle(fontSize: 15, color: Color(0xCCFFFFFF), letterSpacing: 3)),
              ),
              const SizedBox(height: 44),
              AnimatedBuilder(
                animation: bar,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 160,
                    height: 5,
                    child: LinearProgressIndicator(value: bar.value, backgroundColor: const Color(0x33FFFFFF), valueColor: const AlwaysStoppedAnimation(Colors.white)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
