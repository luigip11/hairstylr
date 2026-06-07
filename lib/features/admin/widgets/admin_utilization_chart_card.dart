import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
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
      final statusCounts = controller.activeAppointmentStatusCounts;
      final totalAppointments = controller.activeAppointmentStatusTotal;
      final slices = _statusSlices(statusCounts, totalAppointments);
      final hasData = totalAppointments > 0;

      return AdminPanelShell(
        title: range.title,
        subtitle: range.subtitle,
        headerAction: AdminPopupSelector<AdminUtilizationRange>(
          width: 156,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final chartSize = compact ? 150.0 : 165.0;
            final chart = Padding(
              padding: EdgeInsets.all(compact ? 4 : 12),
              child: SizedBox(
                width: chartSize,
                height: chartSize,
                child: CustomPaint(
                  painter: _AppointmentStatusPiePainter(slices: slices),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalAppointments',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.accentBlueDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'totali',
                          style: TextStyle(color: AppColors.textChartMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            final legend = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...slices.map(
                  (slice) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AppointmentStatusLegendRow(
                      color: slice.color,
                      label: slice.label,
                      value: '${slice.count}',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softPanel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fact_check_rounded,
                        color: AppTheme.accentBlueDark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hasData
                              ? '${range.totalLabel}: $totalAppointments'
                              : 'Nessun appuntamento nel range ${range.label.toLowerCase()}',
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
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: chart),
                  const SizedBox(height: 18),
                  legend,
                ],
              );
            }

            return Row(
              children: [
                chart,
                const SizedBox(width: 24),
                Expanded(child: legend),
              ],
            );
          },
        ),
      );
    });
  }

  List<_AppointmentStatusSlice> _statusSlices(
    Map<String, int> counts,
    int total,
  ) {
    return [
      _AppointmentStatusSlice(
        label: 'Richiesti',
        count: counts['requested'] ?? 0,
        color: AppColors.warningOrange,
        ratio: total == 0 ? 0 : (counts['requested'] ?? 0) / total,
      ),
      _AppointmentStatusSlice(
        label: 'Confermati',
        count: counts['confirmed'] ?? 0,
        color: AppColors.successGreen,
        ratio: total == 0 ? 0 : (counts['confirmed'] ?? 0) / total,
      ),
      _AppointmentStatusSlice(
        label: 'Completati',
        count: counts['completed'] ?? 0,
        color: AppTheme.accentBlueDark,
        ratio: total == 0 ? 0 : (counts['completed'] ?? 0) / total,
      ),
    ];
  }
}

class _AppointmentStatusLegendRow extends StatelessWidget {
  const _AppointmentStatusLegendRow({
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

class _AppointmentStatusSlice {
  const _AppointmentStatusSlice({
    required this.label,
    required this.count,
    required this.color,
    required this.ratio,
  });

  final String label;
  final int count;
  final Color color;
  final double ratio;
}

class _AppointmentStatusPiePainter extends CustomPainter {
  const _AppointmentStatusPiePainter({required this.slices});

  final List<_AppointmentStatusSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..color = AppColors.borderBlueSoft
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    var startAngle = -math.pi / 2;
    for (final slice in slices.where((slice) => slice.ratio > 0)) {
      final sweepAngle = math.pi * 2 * slice.ratio;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..color = slice.color
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _AppointmentStatusPiePainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
