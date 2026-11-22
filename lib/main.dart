
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/status_screen.dart';
import 'state/app_state.dart';
import 'widgets/glass.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const PayirBuyerApp(),
    ),
  );
}

class PayirBuyerApp extends StatelessWidget {
  const PayirBuyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payir Buyer',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),

      // One animated gradient behind every screen; screens are transparent.
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          const AuroraBackground(),
          if (child != null) child,
        ],
      ),

      // Original Payir Buyer app navigation.
      home: const SplashScreen(next: Gate()),
    );
  }
}

// logged out -> Login; no profile -> Registration;
// approved -> Home; else Status.
class Gate extends StatelessWidget {
  const Gate({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    // Wait until the saved session is checked.
    if (s.isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!s.loggedIn) return const LoginScreen();
    if (s.profile == null) return const RegistrationScreen();
    if (s.approved) return const HomeShell();

    return const StatusScreen();
  }
}
