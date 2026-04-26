import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

const _heroBlueTop = AppColors.heroBlueTop;
const _heroBlueBottom = AppColors.heroBlueBottom;
const _heroHairProfileAsset = 'assets/images/hero_hair_profile.png';

class BookingPosterHeader extends StatelessWidget {
  const BookingPosterHeader({super.key, required this.onAdminTap});

  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_heroBlueTop, _heroBlueBottom],
          ),
        ),
        child: Stack(
          children: [
            // background image
            Positioned.fill(
              child: Image.asset(
                _heroHairProfileAsset,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                color: Colors.blue,
              ),
            ),
            Positioned.fill(
              child: ColoredBox(color: _heroBlueBottom.withValues(alpha: 0.2)),
            ),
            // background gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.34),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.46, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // logo
                      const Text(
                        'HAIRSTYLR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'StoryScript',
                          fontSize: 30,
                        ),
                      ),
                      const Spacer(),
                      // admin button
                      InkWell(
                        onTap: onAdminTap,
                        child: Icon(
                          Icons.settings,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 32,
                        ),
                      ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // title
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                      'Agenda degli appuntamenti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                      'Calendario completo del mese, scelta servizio e conferma rapida in pochi tocchi.',
                      style: TextStyle(
                        color: AppColors.textOnHero,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
