import 'package:flutter/material.dart';

class WinkingMoody extends StatelessWidget {
  final double size;

  const WinkingMoody({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF90CAF9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left eye (open)
          Positioned(
            left: size * 0.25,
            top: size * 0.3,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: size * 0.1,
                  height: size * 0.1,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          
          // Right eye (winking)
          Positioned(
            right: size * 0.25,
            top: size * 0.35,
            child: Container(
              width: size * 0.2,
              height: size * 0.05,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(size * 0.025),
              ),
            ),
          ),
          
          // Smile
          Positioned(
            bottom: size * 0.3,
            left: size * 0.25,
            child: Container(
              width: size * 0.5,
              height: size * 0.25,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF1565C0),
                    width: size * 0.05,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 