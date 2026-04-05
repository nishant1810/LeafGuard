import 'package:flutter/material.dart';

enum WeatherRisk { low, moderate, high }

class WeatherWarningCard extends StatelessWidget {
  final WeatherRisk risk;
  final String      conditionText;
  final String?     temperature;
  final String?     humidity;

  const WeatherWarningCard({
    super.key,
    required this.risk,
    required this.conditionText,
    this.temperature,
    this.humidity,
  });

  Color get _bgColor {
    switch (risk) {
      case WeatherRisk.low:
        return Colors.transparent;
      case WeatherRisk.moderate:
        return Colors.transparent;
      case WeatherRisk.high:
        return Colors.transparent;
    }
  }

  Color get _borderColor {
    switch (risk) {
      case WeatherRisk.low:
        return const Color(0xFF4CAF50).withValues(alpha: 0.4);
      case WeatherRisk.moderate:
        return const Color(0xFFFF9800).withValues(alpha: 0.4);
      case WeatherRisk.high:
        return const Color(0xFFF44336).withValues(alpha: 0.45);
    }
  }

  Color get _iconColor {
    switch (risk) {
      case WeatherRisk.low:      return const Color(0xFF4CAF50);
      case WeatherRisk.moderate: return const Color(0xFFFF9800);
      case WeatherRisk.high:     return const Color(0xFFF44336);
    }
  }

  IconData get _icon {
    switch (risk) {
      case WeatherRisk.low:      return Icons.wb_sunny_outlined;
      case WeatherRisk.moderate: return Icons.cloud_outlined;
      case WeatherRisk.high:     return Icons.thunderstorm_outlined;
    }
  }

  String get _riskLabel {
    switch (risk) {
      case WeatherRisk.low:      return 'Low Disease Risk';
      case WeatherRisk.moderate: return 'Moderate Disease Risk';
      case WeatherRisk.high:     return 'High Disease Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ===== ICON =====
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _iconColor, size: 18),
          ),

          const SizedBox(width: 10),

          // ===== TEXT BLOCK =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _riskLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _iconColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conditionText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // ===== TEMP + HUMIDITY =====
                if (temperature != null || humidity != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (temperature != null) ...[
                        const Icon(
                          Icons.thermostat_outlined,
                          color: Colors.white38,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          temperature!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (humidity != null) ...[
                        const Icon(
                          Icons.water_drop_outlined,
                          color: Colors.white38,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          humidity!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ===== RISK BADGE =====
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _iconColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              risk == WeatherRisk.low
                  ? 'LOW'
                  : risk == WeatherRisk.moderate
                  ? 'MED'
                  : 'HIGH',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: _iconColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}