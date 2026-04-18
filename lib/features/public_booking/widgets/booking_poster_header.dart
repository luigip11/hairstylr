import 'package:flutter/material.dart';

const _heroBlueTop = Color(0xFF7BC7FF);
const _heroBlueBottom = Color(0xFF4F83FF);

class BookingPosterHeader extends StatelessWidget {
  const BookingPosterHeader({
    super.key,
    required this.onAdminTap,
  });

  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_heroBlueTop, _heroBlueBottom],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Hairstylr',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAdminTap,
                child: const Text(
                  'Area admin',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Prenota il tuo appuntamento a domicilio.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Calendario completo del mese, scelta servizio e conferma rapida in pochi tocchi.',
            style: TextStyle(
              color: Color(0xFFF1F7FF),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
