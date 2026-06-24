import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class RainbowPaletteButton extends StatelessWidget {
  const RainbowPaletteButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Apri palette colori',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderNeutral, width: 1.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const SweepGradient(
                colors: [
                  Color(0xFFE74856),
                  Color(0xFFFFA500),
                  Color(0xFFF9D64A),
                  Color(0xFF46B450),
                  Color(0xFF2F80ED),
                  Color(0xFF8E44AD),
                  Color(0xFFE74856),
                ],
              ).createShader(bounds),
              child: const Icon(
                Icons.palette_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
