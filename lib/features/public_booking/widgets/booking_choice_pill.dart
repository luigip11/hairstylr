import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

const bookingAccentBlue = AppColors.accentBlue;
const bookingDeepBlue = AppColors.bookingDeepBlue;

class BookingChoicePill extends StatelessWidget {
  const BookingChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? bookingAccentBlue : AppColors.softBlue,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? bookingAccentBlue : AppColors.borderBlue,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? bookingAccentBlue : bookingDeepBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
