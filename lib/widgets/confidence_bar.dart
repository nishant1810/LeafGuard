import 'package:flutter/material.dart';

/// Animated horizontal confidence bar.
/// Green ≥ 75%, Orange 50–75%, Red < 50%.
class ConfidenceBar extends StatefulWidget {
  final double confidence;

  const ConfidenceBar({super.key, required this.confidence});

  @override
  State<ConfidenceBar> createState() => _ConfidenceBarState();
}

class _ConfidenceBarState extends State<ConfidenceBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ===== CAP AT 99% =====
  double get _cappedConfidence =>
      widget.confidence > 0.99 ? 0.99 : widget.confidence;

  Color get _barColor {
    if (_cappedConfidence >= 0.75) return const Color(0xFF4CAF50);
    if (_cappedConfidence >= 0.50) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  String get _confidenceLabel {
    if (_cappedConfidence >= 0.75) return 'High confidence';
    if (_cappedConfidence >= 0.50) return 'Moderate confidence';
    return 'Low confidence';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final double display = _anim.value * _cappedConfidence;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF132218),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ===== HEADER ROW =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Confidence Score',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // ===== SCORE PILL =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _barColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _barColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${(display * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _barColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== ANIMATED BAR =====
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: display,
                  minHeight: 8,
                  backgroundColor:
                  Colors.white.withValues(alpha: 0.08),
                  valueColor:
                  AlwaysStoppedAnimation<Color>(_barColor),
                ),
              ),

              const SizedBox(height: 6),

              // ===== BOTTOM LABELS =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Low',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white24,
                    ),
                  ),
                  Text(
                    _confidenceLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _barColor,
                    ),
                  ),
                  const Text(
                    'High',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}