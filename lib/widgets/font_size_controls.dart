import 'package:flutter/material.dart';
import '../services/theme_manager.dart';

class FontSizeControls extends StatelessWidget {
  const FontSizeControls({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: ThemeManager().fontSizeDelta,
      builder: (context, delta, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF131829),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB08AFF).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'قەبارەی فۆنت',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (delta > -4.0) {
                        ThemeManager().setFontSizeDelta(delta - 2.0);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(100 + (delta * 5)).toInt()}%',
                    style: const TextStyle(color: Color(0xFFB08AFF), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  _buildButton(
                    icon: Icons.add,
                    onPressed: () {
                      if (delta < 10.0) {
                        ThemeManager().setFontSizeDelta(delta + 2.0);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFB08AFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFB08AFF), size: 20),
      ),
    );
  }
}
