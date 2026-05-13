import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_appointment_row.dart';
import 'admin_panel_shell.dart';

class AdminAppointmentsPanel extends StatefulWidget {
  const AdminAppointmentsPanel({super.key});

  @override
  State<AdminAppointmentsPanel> createState() => _AdminAppointmentsPanelState();
}

class _AdminAppointmentsPanelState extends State<AdminAppointmentsPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminAreaController>();
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final listHeight =
        (isLandscape
                ? mediaQuery.size.height * 0.34
                : mediaQuery.size.height * 0.3)
            .clamp(220.0, 380.0)
            .toDouble();

    return Obx(() {
      final selectedAppointments = controller.selectedDateAppointments;

      return AdminPanelShell(
        title: 'Appuntamenti',
        subtitle: 'Seleziona un giorno dal calendario per gestire l\'agenda.',
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AdminAppointmentsCalendar(controller: controller),
              if (selectedAppointments.isNotEmpty) ...[
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  decoration: BoxDecoration(
                    color: AppColors.softPanel,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderBlueSoft),
                  ),
                  child: SizedBox(
                    height: listHeight,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      radius: const Radius.circular(999),
                      thickness: 5,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(right: 18, bottom: 8),
                        itemCount: selectedAppointments.length,
                        itemBuilder: (context, index) {
                          return AdminAppointmentRow(
                            data: selectedAppointments[index],
                            compact: true,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _AdminAppointmentsCalendar extends StatelessWidget {
  const _AdminAppointmentsCalendar({required this.controller});

  final AdminAreaController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const weekdayLabels = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
      final visibleMonth = controller.visibleAppointmentsMonth.value;
      final calendarCells = controller.appointmentCalendarCells;

      return Column(
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.changeAppointmentsMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${monthLong(visibleMonth)} ${visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.bookingDeepBlue,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.changeAppointmentsMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textCalendarMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.28,
            ),
            itemCount: calendarCells.length,
            itemBuilder: (context, index) {
              final date = calendarCells[index];
              if (date == null) {
                return const SizedBox.shrink();
              }

              final hasAppointments = controller.hasAppointmentsOn(date);
              final selectedDate = controller.selectedAppointmentDate.value;
              final isSelected =
                  selectedDate != null && isSameDate(date, selectedDate);
              final isToday = isSameDate(date, dateOnly(DateTime.now()));

              return _AdminCalendarDayCell(
                date: date,
                hasAppointments: hasAppointments,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => controller.selectAppointmentDate(date),
              );
            },
          ),
        ],
      );
    });
  }
}

class _AdminCalendarDayCell extends StatelessWidget {
  const _AdminCalendarDayCell({
    required this.date,
    required this.hasAppointments,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool hasAppointments;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bookingDeepBlue : AppColors.softBlueAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday && !isSelected
                ? AppTheme.accentBlue.withValues(alpha: 0.45)
                : Colors.transparent,
            width: isToday && !isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textNavy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: hasAppointments ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.heroBlueTop : AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
