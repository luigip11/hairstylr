import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/models/booking_support.dart';
import 'booking_choice_pill.dart';

class BookingMonthGrid extends StatelessWidget {
  const BookingMonthGrid({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
  });

  final List<DateTime?> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

    return Column(
      children: [
        Row(
          children: weekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textCalendarMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            if (date == null) {
              return const SizedBox.shrink();
            }

            final isSelected = isSameDate(date, selectedDate);
            final isToday = isSameDate(date, dateOnly(DateTime.now()));

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelect(date),
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected
                      ? bookingAccentBlue
                      : AppColors.softBlueAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isToday && !isSelected
                        ? bookingAccentBlue.withValues(alpha: 0.45)
                        : Colors.transparent,
                    width: isToday && !isSelected ? 3 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected
                          ? bookingAccentBlue
                          : AppColors.textNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
