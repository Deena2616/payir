
import 'package:flutter/material.dart';
import '../../core/language/app_language.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'Tamil';

  bool get isTamil => selectedLanguage == 'Tamil';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),
              Container(
                height: 95,
                width: 95,
                decoration: BoxDecoration(
                  color: const Color(0xFF174D35),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'PAYIR',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF174D35),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isTamil
                    ? 'விவசாயத்தின் புதிய பயணம்!'
                    : 'Welcome to PAYIR!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174D35),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isTamil
                    ? 'சிறந்த விவசாயம், சிறந்த எதிர்காலம்'
                    : 'Smart Farming, Better Future',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF52665A),
                ),
              ),
              const SizedBox(height: 35),
              const Icon(
                Icons.eco_rounded,
                size: 65,
                color: Color(0xFF4E9B68),
              ),
              const SizedBox(height: 25),
              Text(
                isTamil
                    ? 'உங்கள் மொழியைத் தேர்வு செய்யுங்கள்'
                    : 'Choose Your Language',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174D35),
                ),
              ),
              const SizedBox(height: 20),
              languageCard(
                title: 'தமிழ்',
                subtitle: 'Tamil',
                value: 'Tamil',
              ),
              const SizedBox(height: 15),
              languageCard(
                title: 'English',
                subtitle: 'English',
                value: 'English',
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF174D35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isTamil ? 'தொடரவும்' : 'Continue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget languageCard({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedLanguage == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = value;
        });

        AppLanguage.changeLanguage(
          value == 'Tamil' ? 'ta' : 'en',
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF174D35)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF174D35),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: const Color(0xFF174D35),
              size: 27,
            ),
          ],
        ),
      ),
    );
  }
}
