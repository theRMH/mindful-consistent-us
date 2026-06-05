import 'package:flutter/material.dart';

class BackgroundLeaves extends StatelessWidget {
  const BackgroundLeaves({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Bottom-Left Leaf Branch
          Positioned(
            left: -80,
            bottom: -60,
            width: 300,
            height: 300,
            child: Opacity(
              opacity: 0.1, // Soft background transparency
              child: Image.asset(
                'assets/bg_leaf.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Middle-Right Leaf Branch
          Positioned(
            right: -80,
            top: 220,
            width: 260,
            height: 260,
            child: Opacity(
              opacity: 0.1,
              child: Transform.scale(
                scaleX: -1, // Horizontal flip
                child: Transform.rotate(
                  angle: 0.8, // Subtle rotation
                  child: Image.asset(
                    'assets/bg_leaf.png',
                    fit: BoxFit.contain,
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
