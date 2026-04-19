import 'package:flutter/material.dart';

const _heroBlueTop = Color(0xFF7BC7FF);
const _heroBlueBottom = Color(0xFF4F83FF);
const _heroIllustration = Color(0xFFDDE4EE);

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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -24,
              top: -4,
              bottom: -12,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.28,
                  child: SizedBox(
                    width: 430,
                    child: CustomPaint(painter: _HeroHairIllustrationPainter()),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // logo + admin
                  Row(
                    children: [
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: TextButton(
                          onPressed: onAdminTap,
                          child: const Text(
                            'Area admin',
                            style: TextStyle(color: _heroBlueBottom),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // title
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                      'Prenota il tuo appuntamento online',
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
                        color: Color(0xFFF1F7FF),
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

class _HeroHairIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final profilePaint = Paint()
      ..color = _heroIllustration
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final hairPaint = Paint()
      ..color = _heroIllustration
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final profile = Path()
      ..moveTo(size.width * 0.16, size.height * 0.22)
      ..cubicTo(
        size.width * 0.11,
        size.height * 0.25,
        size.width * 0.09,
        size.height * 0.31,
        size.width * 0.10,
        size.height * 0.36,
      )
      ..cubicTo(
        size.width * 0.11,
        size.height * 0.38,
        size.width * 0.13,
        size.height * 0.39,
        size.width * 0.14,
        size.height * 0.40,
      )
      ..cubicTo(
        size.width * 0.11,
        size.height * 0.41,
        size.width * 0.10,
        size.height * 0.44,
        size.width * 0.11,
        size.height * 0.46,
      )
      ..cubicTo(
        size.width * 0.13,
        size.height * 0.47,
        size.width * 0.15,
        size.height * 0.48,
        size.width * 0.16,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.51,
        size.width * 0.13,
        size.height * 0.53,
        size.width * 0.14,
        size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.56,
        size.width * 0.18,
        size.height * 0.57,
        size.width * 0.19,
        size.height * 0.58,
      )
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.60,
        size.width * 0.17,
        size.height * 0.61,
        size.width * 0.18,
        size.height * 0.63,
      )
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.65,
        size.width * 0.23,
        size.height * 0.66,
        size.width * 0.27,
        size.height * 0.66,
      )
      ..cubicTo(
        size.width * 0.31,
        size.height * 0.66,
        size.width * 0.34,
        size.height * 0.69,
        size.width * 0.36,
        size.height * 0.74,
      )
      ..cubicTo(
        size.width * 0.37,
        size.height * 0.77,
        size.width * 0.37,
        size.height * 0.80,
        size.width * 0.37,
        size.height * 0.83,
      )
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.73,
        size.width * 0.33,
        size.height * 0.66,
        size.width * 0.28,
        size.height * 0.61,
      )
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.57,
        size.width * 0.21,
        size.height * 0.53,
        size.width * 0.20,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.19,
        size.height * 0.44,
        size.width * 0.20,
        size.height * 0.40,
        size.width * 0.21,
        size.height * 0.37,
      )
      ..cubicTo(
        size.width * 0.21,
        size.height * 0.33,
        size.width * 0.20,
        size.height * 0.29,
        size.width * 0.19,
        size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.23,
        size.width * 0.17,
        size.height * 0.22,
        size.width * 0.16,
        size.height * 0.22,
      );

    final topHair = Path()
      ..moveTo(size.width * 0.16, size.height * 0.22)
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.03,
        size.width * 0.44,
        size.height * 0.08,
        size.width * 0.56,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.28,
        size.width * 0.81,
        size.height * 0.12,
        size.width * 0.94,
        size.height * 0.19,
      )
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.21,
        size.width * 1.00,
        size.height * 0.24,
        size.width * 1.01,
        size.height * 0.28,
      );

    final middleHair = Path()
      ..moveTo(size.width * 0.27, size.height * 0.25)
      ..cubicTo(
        size.width * 0.39,
        size.height * 0.14,
        size.width * 0.53,
        size.height * 0.20,
        size.width * 0.64,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.36,
        size.width * 0.88,
        size.height * 0.20,
        size.width * 0.98,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width * 1.00,
        size.height * 0.30,
        size.width * 1.01,
        size.height * 0.33,
        size.width * 1.02,
        size.height * 0.37,
      );

    final bottomHair = Path()
      ..moveTo(size.width * 0.36, size.height * 0.41)
      ..cubicTo(
        size.width * 0.47,
        size.height * 0.31,
        size.width * 0.61,
        size.height * 0.36,
        size.width * 0.72,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.83,
        size.height * 0.52,
        size.width * 0.94,
        size.height * 0.39,
        size.width * 1.01,
        size.height * 0.47,
      )
      ..cubicTo(
        size.width * 1.03,
        size.height * 0.49,
        size.width * 1.04,
        size.height * 0.52,
        size.width * 1.04,
        size.height * 0.56,
      );

    final lowerHair = Path()
      ..moveTo(size.width * 0.42, size.height * 0.56)
      ..cubicTo(
        size.width * 0.54,
        size.height * 0.46,
        size.width * 0.68,
        size.height * 0.50,
        size.width * 0.80,
        size.height * 0.58,
      )
      ..cubicTo(
        size.width * 0.89,
        size.height * 0.64,
        size.width * 0.97,
        size.height * 0.55,
        size.width * 1.03,
        size.height * 0.61,
      );

    canvas.drawPath(profile, profilePaint);
    canvas.drawPath(topHair, hairPaint);
    canvas.drawPath(middleHair, hairPaint);
    canvas.drawPath(bottomHair, hairPaint);
    canvas.drawPath(lowerHair, hairPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
