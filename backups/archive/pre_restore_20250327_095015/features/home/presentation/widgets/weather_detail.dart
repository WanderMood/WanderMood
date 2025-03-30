import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1A4A24), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: const Color(0xFF1A4A24).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A4A24),
          ),
        ),
      ],
    );
  }
} 