import 'package:flutter/material.dart';

class AgriHelplineButton extends StatelessWidget {
  final bool compact;

  const AgriHelplineButton({super.key, this.compact = false});

  static const String _displayNumber = '1800-180-1551';

  void _call(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kisan Helpline: $_displayNumber  •  Toll Free 24×7',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ===== COMPACT FAB =====
    if (compact) {
      return FloatingActionButton.small(
        onPressed: () => _call(context),
        backgroundColor: const Color(0xFF1565C0),
        tooltip: 'Kisan Helpline $_displayNumber',
        child: const Icon(Icons.phone, color: Colors.white, size: 18),
      );
    }

    // ===== FULL BANNER =====
    return GestureDetector(
      onTap: () => _call(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,              // ✅ transparent bg
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1565C0)
                .withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ===== PHONE ICON =====
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1565C0)
                      .withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.phone,
                color: Color(0xFF90CAF9),
                size: 17,
              ),
            ),

            const SizedBox(width: 10),

            // ===== TEXT =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kisan Call Centre',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_displayNumber  •  Toll Free  •  24×7',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF90CAF9),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ===== CHEVRON =====
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white38,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}