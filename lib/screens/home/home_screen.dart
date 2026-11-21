
import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation.dart';

const darkGreen = Color(0xFF174D35);
const leafGreen = Color(0xFF4E9B68);
const cream = Color(0xFFF7F8F1);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showMessage(BuildContext context, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$service page coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAYIR',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'SMART FARMING HUB',
                          style: TextStyle(
                            color: leafGreen,
                            fontSize: 9,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _roundButton(Icons.notifications_none_rounded),
                  const SizedBox(width: 10),
                  _roundButton(Icons.person_outline_rounded),
                ],
              ),

              const SizedBox(height: 25),

              // WELCOME BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF174D35),
                      Color(0xFF367B50),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GOOD DAY, FARMER 👋',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Grow More.\nEarn Better.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your farm, your future, our support.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.agriculture_rounded,
                        color: Colors.white.withValues(alpha: 0.25),
                        size: 75,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // WEATHER UPDATE
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2D9),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.wb_sunny_rounded,
                        color: Color(0xFFE9A52E),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weather Update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Check your local forecast',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 17,
                      color: darkGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // GOVERNMENT SCHEMES
              const GovernmentSchemesSection(),

              const SizedBox(height: 27),

              // EXPLORE SERVICES HEADING
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Services',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  Text(
                    'ALL SERVICES',
                    style: TextStyle(
                      color: leafGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 10 SERVICES
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: 1.18,
                children: [
                  _FeatureCard(
                    icon: Icons.grass_rounded,
                    title: 'My Crops',
                    subtitle: 'Manage your crops',
                    color: const Color(0xFFE6F2E8),
                    onTap: () => _showMessage(context, 'My Crops'),
                  ),
                  _FeatureCard(
                    icon: Icons.spa_rounded,
                    title: 'Seeds',
                    subtitle: 'Find quality seeds',
                    color: const Color(0xFFFFF0DB),
                    onTap: () => _showMessage(context, 'Seeds'),
                  ),
                  _FeatureCard(
                    icon: Icons.compost_rounded,
                    title: 'Fertilizers',
                    subtitle: 'Nutrients for crops',
                    color: const Color(0xFFE8EDFA),
                    onTap: () => _showMessage(context, 'Fertilizers'),
                  ),
                  _FeatureCard(
                    icon: Icons.health_and_safety_rounded,
                    title: 'Crop Protection',
                    subtitle: 'Protect your harvest',
                    color: const Color(0xFFF8E8E7),
                    onTap: () => _showMessage(context, 'Crop Protection'),
                  ),
                  _FeatureCard(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Market Prices',
                    subtitle: 'Daily crop rates',
                    color: const Color(0xFFFFF0DB),
                    onTap: () => _showMessage(context, 'Market Prices'),
                  ),
                  _FeatureCard(
                    icon: Icons.biotech_rounded,
                    title: 'Soil Testing',
                    subtitle: 'Know your soil',
                    color: const Color(0xFFE8EDFA),
                    onTap: () => _showMessage(context, 'Soil Testing'),
                  ),
                  _FeatureCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Plant Doctor',
                    subtitle: 'Check plant diseases',
                    color: const Color(0xFFF3E9F7),
                    onTap: () => _showMessage(context, 'AI Plant Doctor'),
                  ),
                  _FeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Crop Calendar',
                    subtitle: 'Crop growth schedule',
                    color: const Color(0xFFE6F2E8),
                    onTap: () => _showMessage(context, 'Crop Calendar'),
                  ),
                  _FeatureCard(
                    icon: Icons.storefront_rounded,
                    title: 'Sell Your Crops',
                    subtitle: 'Sell your harvest',
                    color: const Color(0xFFFFF0DB),
                    onTap: () => _showMessage(context, 'Sell Your Crops'),
                  ),
                  _FeatureCard(
                    icon: Icons.agriculture_rounded,
                    title: 'Equipment Rental',
                    subtitle: 'Rent farm equipment',
                    color: const Color(0xFFE8EDFA),
                    onTap: () => _showMessage(context, 'Equipment Rental'),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // AI ASSISTANT
              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F0E5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology_alt_rounded,
                      color: darkGreen,
                      size: 42,
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask PAYIR AI',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Get smart farming guidance',
                            style: TextStyle(
                              color: Color(0xFF52665A),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: darkGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: PayirBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crop Scanner coming soon'),
              ),
            );
          }
        },
      ),
    );
  }

  static Widget _roundButton(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: darkGreen,
        size: 22,
      ),
    );
  }

}

// GOVERNMENT SCHEMES SECTION
class GovernmentSchemesSection extends StatelessWidget {
  const GovernmentSchemesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Government Schemes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GovernmentSchemesPage(),
                  ),
                );
              },
              child: const Text(
                'See All →',
                style: TextStyle(
                  color: leafGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'Explore benefits and support for farmers',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: const [
            _SchemeCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'PM-KISAN',
              subtitle: 'Farmer income support',
              color: Color(0xFFE6F2E8),
            ),
            _SchemeCard(
              icon: Icons.shield_outlined,
              title: 'PM Fasal Bima',
              subtitle: 'Crop insurance',
              color: Color(0xFFFFF0DB),
            ),
            _SchemeCard(
              icon: Icons.credit_card_rounded,
              title: 'Kisan Credit Card',
              subtitle: 'Farmer credit support',
              color: Color(0xFFE8EDFA),
            ),
            _SchemeCard(
              icon: Icons.grass_rounded,
              title: 'Soil Health Card',
              subtitle: 'Soil testing support',
              color: Color(0xFFF3E9F7),
            ),
          ],
        ),
      ],
    );
  }
}

// SCHEME CARD
class _SchemeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SchemeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EDE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: darkGreen,
              size: 23,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// SEE ALL GOVERNMENT SCHEMES PAGE
class GovernmentSchemesPage extends StatelessWidget {
  const GovernmentSchemesPage({super.key});

  static const List<List<String>> schemes = [
    ['PM-KISAN', 'Financial support for eligible farmers'],
    ['PM Fasal Bima Yojana', 'Crop insurance support'],
    ['Kisan Credit Card', 'Credit support for farming needs'],
    ['Soil Health Card', 'Information about soil nutrients'],
    ['PM Krishi Sinchai Yojana', 'Support for irrigation'],
    ['Agriculture Infrastructure Fund', 'Support for farm infrastructure'],
    ['National Food Security Mission', 'Support for food crop production'],
    ['Paramparagat Krishi Vikas Yojana', 'Support for organic farming'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text(
          'Government Schemes',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFE5EDE5),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE6F2E8),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schemes[index][0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        schemes[index][1],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// EXPLORE SERVICES CARD
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE9EDE5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: darkGreen,
                size: 25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
