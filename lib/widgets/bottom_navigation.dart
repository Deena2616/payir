
import 'package:flutter/material.dart';

class PayirBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PayirBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const green = Color(0xFF287A46);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.home_rounded, 'Home', 0),
          _item(Icons.groups_rounded, 'Community', 1),
          _scannerItem(),
          _item(Icons.search_rounded, 'Search', 3),
          _item(Icons.person_rounded, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? green : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scannerItem() {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Scanner',
                style: TextStyle(
                  fontSize: 10,
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
