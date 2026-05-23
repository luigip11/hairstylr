import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../core/models/booking_support.dart';
import '../../../core/widgets/custom_empty_state.dart';
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

    return Obx(() {
      final selectedAppointments = controller.selectedDateAppointments;
      final hasSelectedDate = controller.selectedAppointmentDate.value != null;
      final listHeight =
          (hasSelectedDate
                  ? (isLandscape
                        ? mediaQuery.size.height * 0.46
                        : mediaQuery.size.height * 0.42)
                  : (isLandscape
                        ? mediaQuery.size.height * 0.34
                        : mediaQuery.size.height * 0.3))
              .clamp(220.0, hasSelectedDate ? 520.0 : 380.0)
              .toDouble();

      return LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;

          return AdminPanelShell(
            title: 'Appuntamenti',
            subtitle:
                'Seleziona un giorno dal calendario per gestire l\'agenda.',
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        );

                        return FadeTransition(
                          opacity: curved,
                          child: SizeTransition(
                            sizeFactor: curved,
                            axisAlignment: -1,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.04),
                                end: Offset.zero,
                              ).animate(curved),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: hasSelectedDate
                          ? _AdminAppointmentsDayStrip(
                              key: const ValueKey('appointments-day-strip'),
                              controller: controller,
                            )
                          : _AdminAppointmentsCalendar(
                              key: const ValueKey('appointments-calendar'),
                              controller: controller,
                            ),
                    ),
                    if (hasSelectedDate) ...[
                      SizedBox(height: compact ? 18 : 26),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 10 : 14,
                          compact ? 10 : 14,
                          compact ? 8 : 10,
                          compact ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softPanel,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderBlueSoft),
                        ),
                        child: SizedBox(
                          height: listHeight,
                          child: selectedAppointments.isEmpty
                              ? const CustomEmptyState(
                                  message:
                                      'Nessun appuntamento per questo giorno.',
                                  height: null,
                                )
                              : Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: const Radius.circular(999),
                                  thickness: 5,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: EdgeInsets.only(
                                      right: compact ? 10 : 18,
                                      bottom: 8,
                                    ),
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
            ),
          );
        },
      );
    });
  }
}

class _AdminAppointmentsCalendar extends StatelessWidget {
  const _AdminAppointmentsCalendar({super.key, required this.controller});

  final AdminAreaController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const weekdayLabels = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
      final visibleMonth = controller.visibleAppointmentsMonth.value;
      final calendarCells = controller.appointmentCalendarCells;

      return LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: compact ? 19 : null,
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
                                style: TextStyle(
                                  color: AppColors.textCalendarMuted,
                                  fontSize: compact ? 11 : 12,
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: compact ? 5 : 8,
                      crossAxisSpacing: compact ? 5 : 8,
                      childAspectRatio: compact ? 1.0 : 1.28,
                    ),
                    itemCount: calendarCells.length,
                    itemBuilder: (context, index) {
                      final date = calendarCells[index];
                      if (date == null) {
                        return const SizedBox.shrink();
                      }

                      final hasAppointments = controller.hasAppointmentsOn(
                        date,
                      );
                      final selectedDate =
                          controller.selectedAppointmentDate.value;
                      final isSelected =
                          selectedDate != null &&
                          isSameDate(date, selectedDate);
                      final isToday = isSameDate(
                        date,
                        dateOnly(DateTime.now()),
                      );

                      return _AdminCalendarDayCell(
                        date: date,
                        compact: compact,
                        hasAppointments: hasAppointments,
                        isSelected: isSelected,
                        isToday: isToday,
                        onTap: () => controller.selectAppointmentDate(date),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _AdminAppointmentsDayStrip extends StatefulWidget {
  const _AdminAppointmentsDayStrip({super.key, required this.controller});

  final AdminAreaController controller;

  @override
  State<_AdminAppointmentsDayStrip> createState() =>
      _AdminAppointmentsDayStripState();
}

class _AdminAppointmentsDayStripState
    extends State<_AdminAppointmentsDayStrip> {
  static const double _cellWidth = 56;
  static const double _cellSpacing = 8;
  late final ScrollController _dayScrollController;
  DateTime? _lastCenteredDate;

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visibleMonth = widget.controller.visibleAppointmentsMonth.value;
      final selectedDate = widget.controller.selectedAppointmentDate.value;
      final daysInMonth = DateTime(
        visibleMonth.year,
        visibleMonth.month + 1,
        0,
      ).day;

      _centerSelectedDate(selectedDate);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;

              return Row(
                children: [
                  _StripHeaderIconButton(
                    tooltip: 'Mese precedente',
                    icon: Icons.chevron_left_rounded,
                    onPressed: () =>
                        widget.controller.changeAppointmentsMonth(-1),
                  ),
                  Expanded(
                    child: Text(
                      '${monthLong(visibleMonth)} ${visibleMonth.year}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: compact ? 18 : null,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bookingDeepBlue,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _StripHeaderIconButton(
                      tooltip: 'Mostra calendario',
                      icon: Icons.calendar_month_rounded,
                      onPressed: widget.controller.clearSelectedAppointmentDate,
                    ),
                  ),
                  _StripHeaderIconButton(
                    tooltip: 'Mese successivo',
                    icon: Icons.chevron_right_rounded,
                    onPressed: () =>
                        widget.controller.changeAppointmentsMonth(1),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView.separated(
                controller: _dayScrollController,
                scrollDirection: Axis.horizontal,
                primary: false,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                itemCount: daysInMonth,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = DateTime(
                    visibleMonth.year,
                    visibleMonth.month,
                    index + 1,
                  );
                  final hasAppointments = widget.controller.hasAppointmentsOn(
                    date,
                  );
                  final isSelected =
                      selectedDate != null && isSameDate(date, selectedDate);
                  final isToday = isSameDate(date, dateOnly(DateTime.now()));

                  return _AdminDayStripCell(
                    date: date,
                    hasAppointments: hasAppointments,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () => widget.controller.selectAppointmentDate(date),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  void _centerSelectedDate(DateTime? selectedDate) {
    if (selectedDate == null ||
        (_lastCenteredDate != null &&
            isSameDate(selectedDate, _lastCenteredDate!))) {
      return;
    }

    _lastCenteredDate = selectedDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_dayScrollController.hasClients) {
        return;
      }

      final itemExtent = _cellWidth + _cellSpacing;
      final targetCenter = (selectedDate.day - 1) * itemExtent + _cellWidth / 2;
      final viewportWidth = _dayScrollController.position.viewportDimension;
      final maxScrollExtent = _dayScrollController.position.maxScrollExtent;
      final targetOffset = (targetCenter - viewportWidth / 2).clamp(
        0.0,
        maxScrollExtent,
      );

      _dayScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _StripHeaderIconButton extends StatelessWidget {
  const _StripHeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.bookingDeepBlue),
    );
  }
}

class _AdminDayStripCell extends StatelessWidget {
  const _AdminDayStripCell({
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
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bookingDeepBlue : AppColors.softBlueAlt,
          borderRadius: BorderRadius.circular(18),
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
              weekdayShort(date),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textCalendarMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textNavy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: hasAppointments ? 14 : 0,
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

class _AdminCalendarDayCell extends StatelessWidget {
  const _AdminCalendarDayCell({
    required this.date,
    required this.compact,
    required this.hasAppointments,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool compact;
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
                fontSize: compact ? 15 : 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: compact ? 2 : 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: hasAppointments ? (compact ? 12 : 16) : 0,
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
