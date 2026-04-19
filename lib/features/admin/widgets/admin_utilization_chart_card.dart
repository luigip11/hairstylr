import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_theme.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';
import 'admin_popup_selector.dart';

class AdminUtilizationChartCard extends GetView<AdminAreaController> {
  const AdminUtilizationChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final range = controller.selectedUtilizationRange.value;
      final totalSlots = controller.activeSlotCapacity;
      final bookedSlots = controller.activeBookedAppointments;
      final remainingSlots = controller.activeRemainingSlots;
      final bookedRatio = controller.activeBookedRatio.clamp(0.0, 1.0);
      final hasData = totalSlots > 0;

      return AdminPanelShell(
        title: range.title,
        subtitle: range.subtitle,
        headerAction: AdminPopupSelector<AdminUtilizationRange>(
          width: 182,
          value: range,
          items: controller.utilizationRanges
              .map(
                (item) => AdminPopupSelectorItem<AdminUtilizationRange>(
                  value: item,
                  label: item.label,
                ),
              )
              .toList(growable: false),
          onChanged: controller.selectUtilizationRange,
        ),
        child: hasData
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 165,
                      height: 165,
                      child: CustomPaint(
                        painter: _UtilizationPiePainter(
                          bookedRatio: bookedRatio,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(bookedRatio * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accentBlueDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'occupati',
                                style: TextStyle(color: Color(0xFF6A7485)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UtilizationLegendRow(
                          color: AppTheme.accentBlue,
                          label: 'Prenotati',
                          value: '$bookedSlots',
                        ),
                        const SizedBox(height: 12),
                        _UtilizationLegendRow(
                          color: const Color(0xFFB8CCE9),
                          label: 'Disponibili',
                          value: '$remainingSlots',
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FE),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: AppTheme.accentBlueDark,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${range.totalLabel}: $totalSlots',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentBlueDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                'Nessuna disponibilita disponibile per la vista ${range.label.toLowerCase()}. Aggiorna il setup iniziale per vedere il grafico.',
              ),
      );
    });
  }
}

class _UtilizationLegendRow extends StatelessWidget {
  const _UtilizationLegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.accentBlueDark,
          ),
        ),
      ],
    );
  }
}

class _UtilizationPiePainter extends CustomPainter {
  const _UtilizationPiePainter({required this.bookedRatio});

  final double bookedRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * bookedRatio;

    final availablePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..color = const Color(0xFFD9E5F8)
      ..strokeCap = StrokeCap.round;

    final bookedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..shader = const LinearGradient(
        colors: [AppTheme.accentBlue, AppTheme.accentBlueDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, availablePaint);

    if (bookedRatio > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, bookedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _UtilizationPiePainter oldDelegate) {
    return oldDelegate.bookedRatio != bookedRatio;
  }
}
