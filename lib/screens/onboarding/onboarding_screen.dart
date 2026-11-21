
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F1),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.agriculture_rounded,
                  size: 110,
                  color: Color(0xFF174D35),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Welcome to PAYIR',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174D35),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Your Smart Farming Companion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF52665A),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Grow Better. Earn Better. Farm Smarter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF52665A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
