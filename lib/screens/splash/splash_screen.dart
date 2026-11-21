
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/language');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F1),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 125,
                width: 125,
                decoration: BoxDecoration(
                  color: const Color(0xFF174D35),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'PAYIR',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174D35),
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Smart Farming, Better Future',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF52665A),
                ),
              ),
              const SizedBox(height: 35),
              const CircularProgressIndicator(
                color: Color(0xFF4E9B68),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
